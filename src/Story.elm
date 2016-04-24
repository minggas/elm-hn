module Story where

import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import String

import HN exposing (items)

-- hacker news items, filtered into just stories
stories : Signal (List HN.Item)
stories = Signal.map (List.filter isStory) items.signal

-- convert an item to a story (if it is)
isStory : HN.Item -> Bool
isStory item = item.kind == "story"

-- render all stories
viewStories : List HN.Item -> Html
viewStories stories =
    Html.body [] <| List.map viewStory stories

-- view a single story
viewStory : HN.Item -> Html
viewStory item =
    div [ style storyStyle ] 
        [ storyLink item
        , br [] []
        , span [ style infoStyle ] [ info item ]
        ]

-- 
storyLink : HN.Item -> Html
storyLink item = 
    a 
        [ style linkStyle, href <| HN.link item, target "_blank" ]
        [ text item.title ]

-- how to render a story div
storyStyle =
    [ ("margin", "0")
    , ("padding", "12px 30px")
    , ("background-color", "#fff")
    , ("overflow", "hidden")
    , ("text-overflow", "ellipsis")
    , ("white-space", "nowrap")
    , ("border-top", "1px solid #fda")
    , ("font", "Helvetica")
    ]

-- how to render a story link
linkStyle =
    [ ("text-decoration", "none")
    , ("color", "#a52")
    ]

info item =
    text <| String.concat
        [ "posted by "
        , item.by
        , " ("
        , toString item.score
        , " points)"
        ]

infoStyle = 
    [ ("color", "#aaa")
    , ("font-size", "12px")
    ]