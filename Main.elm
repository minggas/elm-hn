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

{-| The list of items to show. -}
type View = Top | Newest | Show | Ask

{-| The Model is a list of stories, the view type, and loading flag. -}
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
    | ShowShow
    | ShowAsk
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
        [ stylesheet.node
        , header model
        , div [ stylesheet.id Content ] (viewStories stylesheet model.stories)
        , loader model
        ]

{-| Renders the title header and controls. -}
header : Model -> Html Msg
header model =
    div [ stylesheet.id Header ]
        [ span [ stylesheet.id Logo ] [ text "Hacker News Troll" ]
        , span [ stylesheet.id Controls ]
            [ if model.view == Top then
                b [ stylesheet.class Enabled ] [ text "Top Stories" ]
              else
                a [ href "#", onClick ShowTop ] [ text "Top Stories" ]
            , text " • "
            , if model.view == Newest then
                b [ stylesheet.class Enabled ] [ text "New" ]
              else
                a [ href "#", onClick ShowNewest ] [ text "New" ]
            , text " • "
            , if model.view == Show then
                b [ stylesheet.class Enabled ] [ text "Show" ]
              else
                a [ href "#", onClick ShowShow ] [ text "Show" ]
            , text " • "
            , if model.view == Ask then
                b [ stylesheet.class Enabled ] [ text "Ask" ]
              else
                a [ href "#", onClick ShowAsk ] [ text "Ask" ]
            ]
        ]

{-| If we're currently updating the story list, indicate with a gif. -}
loader : Model -> Html Msg
loader model =
    div [ stylesheet.id Loader ]
        <| if model.loading then [ img [ src "loader.gif" ] [] ] else []

{-| Every minute, get the top 30 stories from HN. -}
latest : Model -> Sub Msg
latest model =
    every minute Get

{-| Update the model. -}
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Get time -> downloadStories model time
        Refresh stories -> updateStories model stories
        ShowTop -> updateView model Top
        ShowNewest -> updateView model Newest
        ShowShow -> updateView model Show
        ShowAsk -> updateView model Ask
        None -> (model, Cmd.none)

{-| Download new stories. -}
downloadStories : Model -> Time.Time -> (Model, Cmd Msg)
downloadStories model time =
    let items =
        case model.view of
            Top -> HN.top
            Newest -> HN.new
            Show -> HN.showHN
            Ask -> HN.askHN
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
