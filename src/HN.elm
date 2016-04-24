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
    , time : Float
    , score : Int
    }

-- downloaded stories
items : Signal.Mailbox (List Item)
items = Signal.mailbox []

-- base endpoint of all hn queries
v0 = "https://hacker-news.firebaseio.com/v0/"
yc = "https://news.ycombinator.com/item?id="

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
rank : Float -> Item -> Float
rank time item =
    let age = time - item.time in
    let hours = (age + 7200) / 3600 in
    let rank = case item.score of
        0 -> 0
        n -> (0.8 ^ (n - 1)) / (1.8 ^ hours)
    in
    case item.url of
        Just _ -> rank
        Nothing -> rank * 0.4

--
link : Item -> String
link item =
    case item.url of
        Just url -> url
        Nothing -> yc ++ (toString item.id)
        
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
        ("time" := Json.float)
        ("score" := Json.int)
