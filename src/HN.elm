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
    , time : Float
    , score : Int
    , url : Maybe String
    , kids : Int
    }

-- downloaded stories
items : Signal.Mailbox (Time.Time, List Item)
items = Signal.mailbox (0.0, [])

-- base endpoint of all hn queries
v0 = "https://hacker-news.firebaseio.com/v0/"
yc = "https://news.ycombinator.com/item?id="

-- download the top N stories
topStories : Int -> Time.Time -> Task.Task Http.Error ()
topStories n time =
    let url = v0 ++ "topstories.json" in
    Http.get (Json.list Json.int) url
        `andThen` (Task.sequence << List.map item << List.take n)
        `andThen` (Signal.send items.address << (,) time)

-- download an individual hn item
item : Int -> Task.Task Http.Error Item
item id = Http.get decoder (v0 ++ "item/" ++ (toString id) ++ ".json")

-- calculate the rank of an item
rank : Time.Time -> Item -> Float
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
        Nothing -> comments item

comments : Item -> String
comments item = yc ++ (toString item.id)

-- json decoder into hn item record
decoder : Json.Decoder Item
decoder =
    Json.object8 Item
        ("id" := Json.int)
        ("type" := Json.string)
        ("title" := Json.string)
        ("by" := Json.string)
        ("time" := Json.float)
        ("score" := Json.int)
        (Json.maybe <| "url" := Json.string)
        (commentsDecoder)

-- count the number of child items when decoding
commentsDecoder : Json.Decoder Int
commentsDecoder =
    Json.oneOf
        [ Json.map List.length <| "kids" := Json.list Json.int
        , Json.succeed 0
        ]
