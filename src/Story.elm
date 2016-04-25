module Story where

import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import String
import Time

import HN exposing (items)

type alias Story =
    { item : HN.Item
    , rank : Float
    }

-- hacker news items, filtered into just stories
stories : Signal (List Story)
stories = 
    let f = \(t, items) -> List.filterMap (story t) <| items in
    Signal.map f items.signal

-- convert an item to a story (if it is)
story : Time.Time -> HN.Item -> Maybe Story
story time item =
    if item.kind == "story" then
        Just <| Story item (HN.rank time item)
    else
        Nothing
