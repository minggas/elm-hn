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
    { init = (Model [] Top, perform ignore Get now)
    , subscriptions = latest
    , update = update
    , view = view
    }

{-| Wrap a list of rendered Stories into a parent HTML element. -}
view : Model -> Html Msg
view model =
    let content =
        div [ css.id Content ] (viewStories css <| rankedStories model.stories)
    in
    div [] [ css.node, header, content ]

header : Html Msg
header =
    div [ css.id Header ]
        [ span [ css.id Logo ] [ text "Hacker News Troll" ]
        ] 

{-| Every minute, get the top 30 stories from HN. -}
latest : Model -> Sub Msg
latest model = every minute Get

{-| Update the model. -}
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Get time -> (model, aggregate model time)
        Refresh stories -> ({ model | stories = stories }, Cmd.none)
        ShowTop -> ({model | view = Top }, perform ignore Get now)
        ShowNewest -> ({model | view = Newest }, perform ignore Get now)
        None -> (model, Cmd.none)

{-| Download new stories. -}
aggregate : Model -> Time.Time -> Cmd Msg
aggregate model time =
    let items =
        case model.view of
            Top -> HN.top
            Newest -> HN.new
    in
    perform ignore Refresh <| stories 30 time items

{-| Sort all the stories in the model based on their rank. -}
rankedStories : List Story -> List Story
rankedStories = List.sortBy (\s -> s.rank)

{-| Helper to ignore any error condition. -}
ignore : a -> Msg
ignore _ = None
