module Main where

import Html
import Http
import Task exposing (andThen)
import Time exposing (every, minute)

import HN exposing (..)
import Story exposing (..)
import View exposing (..)

type alias Model =
    { stories : List Story
    }

-- model update actions
type Action
    = Refresh (List Story)

-- the final view of all the hn stories
main : Signal Html.Html
main = 
    let stories = Signal.foldp update (Model []) aggregate in
    Signal.map (viewStories << rankedStories) stories

-- every minute get the top stories
port latest : Signal (Task.Task Http.Error ())
port latest = Signal.map (HN.topStories 30) <| every minute

-- whenever we refetch the stories, perform a refresh
aggregate : Signal Action
aggregate = Signal.map Refresh stories

-- return the list of items, sorted by page rank
rankedStories : Model -> List Story
rankedStories model = List.sortBy (\s -> s.rank) model.stories

-- aggregate stories and handle interface
update : Action -> Model -> Model
update action model =
    case action of
        Refresh stories -> { model | stories = stories }
