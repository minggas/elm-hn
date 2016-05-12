module Main exposing (..)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Task exposing (perform)
import Time exposing (Time, every, minute, now)

import Story exposing (..)
import Styles exposing (..)
import View exposing (..)

{-| The Model is just a list of stories. -}
type alias Model = List Story

{-| Interface and mailbox signals combine into Actions. -}
type Action
    = Get Time
    | Refresh Model
    | None

{-| The final, aggregated model transformed to HTML. -}
main : Program Never
main = App.program
    { init = ([], perform ignore Get now)
    , subscriptions = latest
    , update = aggregate
    , view = view
    }

{-| Wrap a list of rendered Stories into a parent HTML element. -}
view : Model -> Html Action
view model = 
     Html.body [style [Styles.font]] <| viewStories <| rankedStories model

{-| Every minute, get the top 30 stories from HN. -}
latest : Model -> Sub Action
latest model = every minute Get

--{-| Update the model. -}
aggregate : Action -> Model -> (Model, Cmd Action)
aggregate action model =
    case action of
        Get time -> (model, perform ignore Refresh <| Story.stories 30 time) 
        Refresh stories -> (stories, Cmd.none)
        None -> (model, Cmd.none)

{-| Sort all the stories in the model based on their rank. -}
rankedStories : List Story -> List Story
rankedStories = List.sortBy (\s -> s.rank)

{-| Helper to ignore any error condition. -}
ignore : a -> Action
ignore _ = None