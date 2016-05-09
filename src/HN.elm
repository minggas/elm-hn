module HN where

import Json.Decode as Json exposing ((:=))
import Http
import String
import Task exposing (andThen)
import Time

{-| End-points for the HN API and item comment pages. -}
v0 = "https://hacker-news.firebaseio.com/v0/"
yc = "https://news.ycombinator.com/item?id="

{-| A parsed JSON item from HN. -}
type alias Item =
    { id : Int
    , kind : String
    , title : String
    , by : String
    , time : Float
    , score : Int
    , url : Maybe String
    , kids : List Int
    }

{-| A mailbox for keeping track of recently downloaded Items from HN -}
items : Signal.Mailbox (Time.Time, List Item)
items = Signal.mailbox (0.0, [])

{-| Task to download the last N Items on HN. -}
topStories : Int -> Time.Time -> Task.Task Http.Error ()
topStories n time =
    let url = v0 ++ "topstories.json" in
    Http.get (Json.list Json.int) url
        `andThen` (Task.sequence << List.map item << List.take n)
        `andThen` (Signal.send items.address << (,) time)

{- Task to download an individual Item from HN. -}
item : Int -> Task.Task Http.Error Item
item id = Http.get decoder (v0 ++ "item/" ++ (toString id) ++ ".json")

{-| Returns either an Item's external URL or its comments page. -}
link : Item -> String
link item = Maybe.withDefault (comments item) item.url

{-| Returns the URL to the comments of an Item. -}
comments : Item -> String
comments item = yc ++ (toString item.id)

{-| HN Item JSON decoder. -}
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
        (Json.oneOf
            [ "kids" := Json.list Json.int
            , Json.succeed []
            ])
