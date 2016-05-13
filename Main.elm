module Main exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.App as App
import Task exposing (perform)
import Time exposing (Time, every, minute, now)

import HN exposing (..)
import Story exposing (..)
import Styles exposing (..)
import View exposing (..)

{-| Top stories or Newest. -}
type View = Top | Newest

{-| The Model is just a list of stories. -}
type alias Model =
    { stories : List Story
    , view : View
    , loading : Bool
    }

{-| All the possible Cmd messages to update the model. -}
type Msg
    = Get Time
    | Refresh (List Story)
    | ShowTop
    | ShowNewest
    | None

{-| The final, aggregated model rendered to HTML. -}
main : Program Never
main = App.program
    { init = (Model [] Top False, perform ignore Get now)
    , subscriptions = latest
    , update = update
    , view = view
    }

{-| Wrap a list of rendered Stories into a parent HTML element. -}
view : Model -> Html Msg
view model =
    div []
        [ css.node
        , header model
        , div [ css.id Content ] (viewStories css model.stories)
        , loader model
        ]

{-| Renders the title header and controls. -}
header : Model -> Html Msg
header model =
    div [ css.id Header ]
        [ span [ css.id Logo ] [ text "Hacker News Troll" ]
        , span [ css.id Controls ]
            [ if model.view == Top then
                b [ css.class Enabled ] [ text "Top Stories" ]
              else
                a [ href "#", onClick ShowTop ] [ text "Top Stories" ]
            , text " • "
            , if model.view == Newest then
                b [ css.class Enabled ] [ text "New" ]
              else
                a [ href "#", onClick ShowNewest ] [ text "New" ]
            ]
        ]

{-| If we're currently updating the story list, indicate with a gif. -}
loader : Model -> Html Msg
loader model =
    div [ css.id Loader ]
        <| if model.loading then [ img [ src "loader.gif" ] [] ] else []

{-| Every minute, get the top 30 stories from HN. -}
latest : Model -> Sub Msg
latest model = every minute Get

{-| Update the model. -}
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Get time -> downloadStories model time
        Refresh stories -> updateStories model stories
        ShowTop -> updateView model Top
        ShowNewest -> updateView model Newest
        None -> (model, Cmd.none)

{-| Download new stories. -}
downloadStories : Model -> Time.Time -> (Model, Cmd Msg)
downloadStories model time =
    let items =
        case model.view of
            Top -> HN.top
            Newest -> HN.new
    in
    ( { model | loading = True }
    , perform ignore Refresh <| stories 30 time items
    )

{-| Update the model with a list of new stories (sorted by rank). -}
updateStories : Model -> List Story -> (Model, Cmd Msg)
updateStories model stories =
    ( { model
      | stories = List.sortBy (\s -> s.rank) stories
      , loading = False
      }
    , Cmd.none
    )

{-| Update the current view style and download the stories for it. -}
updateView : Model -> View -> (Model, Cmd Msg)
updateView model view =
    ( { model | view = view }
    , perform ignore Get now
    )

{-| Helper to ignore any error condition. -}
ignore : a -> Msg
ignore _ = None
