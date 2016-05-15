module HN exposing (..)

import Json.Decode as Json exposing ((:=))
import Http exposing (Error)
import String exposing (concat)
import Task exposing (Task, andThen, sequence)

{-| End-point for the HN API. -}
v0 : String
v0 = "https://hacker-news.firebaseio.com/v0/"

{-| End-point for an item on HN. -}
yc : String
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

{-| Download IDs from FirebaseIO. -}
fetch : String -> Task Error (List Int)
fetch =
    Http.get (Json.list Json.int) << (++) v0 

{-| Download the most recent N items from a list if IDs. -}
items : Int -> Task Error (List Int) -> Task Error (List Item)
items n task =
    task `andThen` (sequence << List.map item << List.take n)

{-| Task to download the top Item IDs on HN. -}
top : Task Error (List Int)
top = 
    fetch "topstories.json"

{-| Task to download the newest Item IDs on HN. -}
new : Task Error (List Int)
new = 
    fetch "newstories.json"

{-| Task to download the latest show HN item IDs. -}
showHN : Task Error (List Int)
showHN = 
    fetch "showstories.json"

{-| Task to download the latest ask HN item IDs. -}
askHN : Task Error (List Int)
askHN = 
    fetch "askstories.json"

{- Task to download an individual Item from HN. -}
item : Int -> Task Error Item
item id = 
    Http.get decoder <| concat [ v0, "item/", toString id, ".json" ]

{-| Returns either an Item's external URL or its comments page. -}
link : Item -> String
link item = 
    Maybe.withDefault (comments item) item.url

{-| Returns the URL to the comments of an Item. -}
comments : Item -> String
comments item =
    yc ++ (toString item.id)

{-| URLs are optionally found. -}
url : Json.Decoder (Maybe String)
url =
    Json.maybe <| "url" := Json.string

{-| JSON decoder for a list of HN item child IDs. -}
kids : Json.Decoder (List Int)
kids =
    Json.oneOf
        [ "kids" := Json.list Json.int
        , Json.succeed []
        ]

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
        (url)
        (kids)
