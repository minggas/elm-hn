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

-- render all stories
viewStories : List Story -> Html
viewStories stories =
    Html.body [] <| List.map viewStory stories

-- view a single story
viewStory : Story -> Html
viewStory story =
    div [ style storyStyle ] 
        [ storyLink story.item
        , br [] []
        , span [ style infoStyle ] [ info story ]
        , commentsLink story.item
        ]

-- 
storyLink : Story -> Html
storyLink story = 
    a 
        [ style linkStyle
        , href <| HN.link story.item
        , target "_blank"
        ]
        [ text story.item.title ]

commentsLink : Story -> Html
commentsLink story =
    a
        [ style commentsStyle
        , href <| HN.comments story.item
        , target "_blank"
        ]
        [ text <| (toString story.item.kids) ++ " comments" ]

info : Story -> Html.Html
info story =
    text <| String.concat
        [ "posted by "
        , story.item.by
        , " ("
        , toString story.item.score
        , " points)"
        , " | "
        ]

-- how to render a story div
storyStyle : List (String, String)
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
linkStyle : List (String, String)
linkStyle =
    [ ("color", "#a52")
    ]

commentsStyle : List (String, String)
commentsStyle =
    linkStyle ++ infoStyle ++ [("color", "#d73")]

infoStyle : List (String, String)
infoStyle = 
    [ ("color", "#aaa")
    , ("font-size", "12px")
    ]