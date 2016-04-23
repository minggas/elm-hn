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

-- the final view of all the hn stories
main : Signal Html.Html
main = 
    let items = Signal.foldp aggregate [] stories in
    Signal.map viewStories items

-- every minute get the top stories
port latest : Signal (Task.Task Http.Error ())
port latest = Signal.map (HN.topStories 26) (Time.every Time.minute)

-- accumulate new stories with existing ones and sort by time
aggregate : List Story -> List Story -> List Story
aggregate new old = List.sortBy (\s -> s.item.time) new
