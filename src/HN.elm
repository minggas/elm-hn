module HN exposing (..)

import Json.Decode as Json exposing ((:=))
import Http exposing (Error)
import Task exposing (Task, andThen, sequence)

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

{-| Download the most recent N items from a list if IDs. -}
items : Int -> Task Error (List Int) -> Task Error (List Item)
items n task = task `andThen` (sequence << List.map item << List.take n)

{-| Task to download the top Item IDs on HN. -}
top : Task Error (List Int)
top = Http.get (Json.list Json.int) <| v0 ++ "topstories.json"

{-| Task to download the newest Item IDs on HN. -}
new : Task Error (List Int)
new = Http.get (Json.list Json.int) <| v0 ++ "newstories.json"

{- Task to download an individual Item from HN. -}
item : Int -> Task Error Item
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
