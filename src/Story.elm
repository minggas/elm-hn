module Story exposing (..)

import Http exposing (Error)
import Task exposing (Task)
import Time

import HN exposing (..)

{-| A HN Item where the kind is "story", and ranked. -}
type alias Story =
    { item : HN.Item
    , rank : Float
    }

{-| A filtered list of HN Items that are ranked by time. -}
stories : Int -> Time.Time -> Task Error (List Int) -> Task Error (List Story)
stories n time ids =
    Task.map (List.filterMap (story time)) (HN.items n ids)

{-| Filters stories from a list of HN Items and ranks them. -}
filterStories : Time.Time -> List HN.Item -> List Story
filterStories time items =
    List.filterMap (story time) <| items 

{-| Create a Story from a HN Item if it is a Story. -}
story : Time.Time -> HN.Item -> Maybe Story
story time item =
    if item.kind == "story" then
        Just (Story item <| rank time item)
    else
        Nothing

{-| Calculates the page rank of an Item at a given Time. -}
rank : Time.Time -> HN.Item -> Float
rank time item =
    let age = (time + 7200 - item.time) / 3600 in
    let rank = case item.score of
        0 -> 0
        n -> (0.8 ^ (n - 1)) / (1.8 ^ age)
    in
    case item.url of
        Just _ -> rank
        Nothing -> rank * 0.4