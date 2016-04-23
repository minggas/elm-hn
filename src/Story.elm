module Story where

import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import String

import HN exposing (items)

type alias Story =
    { item : HN.Item
    , link : String
    , rank : Float
    }

-- hacker news items, filtered into just stories
stories : Signal (List Story)
stories = Signal.map (List.filterMap story) items.signal

-- url to a story based on yc
yc = "https://news.ycombinator.com/item?id="

-- convert an item to a story (if it is)
story : HN.Item -> Maybe Story
story item =
    if item.kind == "story" then
        let link = case item.url of
            Nothing -> yc ++ (toString item.id)
            Just url -> url
        in
        Story item link 0.0 |> Just 
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
        [ storyLink story
        , br [] []
        , span [ style infoStyle ] [ info story ]
        ]

-- 
storyLink story = 
    a 
        [ style linkStyle, href story.link, target "_blank" ]
        [ text story.item.title ]

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

info story =
    text <| String.concat
        [ "posted by "
        , story.item.by
        , " ("
        , toString story.item.score
        , " points)"
        ]

infoStyle = 
    [ ("color", "#aaa")
    , ("font-size", "12px")
    ]