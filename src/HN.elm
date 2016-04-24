module HN where

import Json.Decode as Json exposing ((:=))
import Http exposing (..)
import String
import Task exposing (andThen)
import Time

type alias Item =
    { id : Int
    , kind : String
    , title : String
    , by : String
    , text : Maybe String
    , url : Maybe String
    , time : Int
    , score : Int
    }

-- downloaded stories
items : Signal.Mailbox (List Item)
items = Signal.mailbox []

-- base endpoint of all hn queries
v0 = "https://hacker-news.firebaseio.com/v0/"

-- download the top N stories
topStories : Int -> a -> Task.Task Http.Error ()
topStories n _ =
    let url = v0 ++ "topstories.json" in
    Http.get (Json.list Json.int) url
        `andThen` (Task.sequence << List.map item << List.take n)
        `andThen` (Signal.send items.address)

-- download an individual hn item
item : Int -> Task.Task Http.Error Item
item id = Http.get decoder (v0 ++ "item/" ++ (toString id) ++ ".json")

-- calculate the rank of an item
rank : Int -> Int -> String -> Float
rank score age link =
    let hours = (age + 7200) // 3600 in
    let rank = case score of
        0 -> 0
        n -> (0.8 ^ (n - 1)) / (1.8 ^ (toFloat hours))
    in
    if String.length link == 0 then
        rank * 0.4
    else
        rank

-- json decoder into hn item record
decoder : Json.Decoder Item
decoder =
    Json.object8 Item
        ("id" := Json.int)
        ("type" := Json.string)
        ("title" := Json.string)
        ("by" := Json.string)
        (Json.maybe <| "text" := Json.string)
        (Json.maybe <| "url" := Json.string)
        ("time" := Json.int)
        ("score" := Json.int)
