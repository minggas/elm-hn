module Main exposing (main)

import Html exposing (..)
import Html.App as App
import Task exposing (perform)
import Time exposing (Time, every, minute, now)

import Story exposing (..)
import Styles exposing (..)
import View exposing (..)

{-| The Model is just a list of stories. -}
type alias Model = List Story

{-| All the possible Cmd messages to update the model. -}
type Msg
    = Get Time
    | Refresh Model
    | None

{-| The final, aggregated model rendered to HTML. -}
main : Program Never
main = App.program
    { init = ([], perform ignore Get now)
    , subscriptions = latest
    , update = aggregate
    , view = view
    }

{-| Wrap a list of rendered Stories into a parent HTML element. -}
view : Model -> Html Msg
view model = Html.div [] <| Styles.css :: (viewStories <| rankedStories model)

{-| Every minute, get the top 30 stories from HN. -}
latest : Model -> Sub Msg
latest model = every minute Get

--{-| Update the model. -}
aggregate : Msg -> Model -> (Model, Cmd Msg)
aggregate msg model =
    case msg of
        Get time -> (model, perform ignore Refresh <| Story.stories 30 time) 
        Refresh stories -> (stories, Cmd.none)
        None -> (model, Cmd.none)

{-| Sort all the stories in the model based on their rank. -}
rankedStories : List Story -> List Story
rankedStories = List.sortBy (\s -> s.rank)

{-| Helper to ignore any error condition. -}
ignore : a -> Msg
ignore _ = None
