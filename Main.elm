module Main where

import Json.Decode as Json exposing ((:=))
import Html
import Html.Attributes
import Html.Events
import Http
import Task exposing (andThen)
import Time

import HN
import Story exposing (..)

type Action
    = Refresh (List HN.Item)

type alias Model =
    { stories : List Story
    }

-- the final view of all the hn stories
main : Signal Html.Html
main = 
    let new = Signal.foldp aggregate (Model 0 []) stories in
    Signal.map (viewStories << rankedStories) new

-- every minute get the top stories
port latest : Signal (Task.Task Http.Error ())
port latest = Signal.map (HN.topStories 30) <| Time.every Time.minute

-- accumulate new stories with existing ones and sort by time
aggregate : Action -> Model -> Model
aggregate action model =
    case action of
        Refresh stories -> { model | stories = stories }

-- return the list of items, sorted by page rank
rankedStories : Model -> List Story
rankedStories model = List.sortBy (\s -> s.rank) model.stories
