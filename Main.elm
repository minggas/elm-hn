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
    = Rank Time.Time
    | Refresh (List HN.Item)

type alias Model =
    { time : Time.Time
    , stories : List HN.Item
    }

-- the final view of all the hn stories
main : Signal Html.Html
main = 
    let items = Signal.foldp aggregate (Model 0 []) update in
    Signal.map (viewStories << rankedStories) items

-- every minute get the top stories
port latest : Signal (Task.Task Http.Error ())
port latest = Signal.map (HN.topStories 30) <| Time.every Time.minute

-- periodically update the stories and rankings
update : Signal Action
update =
    let refresh = Signal.map Refresh stories in
    let rankings = Signal.map Rank << Time.every <| 10 * Time.second in
    Signal.merge rankings refresh

-- accumulate new stories with existing ones and sort by time
aggregate : Action -> Model -> Model
aggregate action model =
    case action of
        Rank now -> { model | time = now }
        Refresh stories -> { model | stories = stories }

-- return the list of items, sorted by page rank
rankedStories : Model -> List HN.Item
rankedStories model = List.sortBy (HN.rank model.time) model.stories
