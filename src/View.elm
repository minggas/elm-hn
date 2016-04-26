module View where

import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import String

import HN exposing (..)
import Story exposing (..)

-- render all stories
viewStories : List Story -> Html
viewStories stories =
    Html.body [ style [ font ] ] <| List.map view stories

-- create the div to a post
view : Story -> Html
view story =
    div [ style storyClass ]
        [ title story.item
        , br [] []
        , span [ style infoClass ] [ info story.item ]
        , comments story.item
        ]

-- create the link to the url of a post
title : HN.Item -> Html
title item = link titleClass (HN.link item) [ text item.title ]

-- create the link to the comments of a post
comments : HN.Item -> Html
comments item =
    link commentClass (HN.comments item)
        [ text <| (toString item.kids) ++ " comments"
        ]

-- common anchor pattern
link : List (String, String) -> String -> List Html -> Html
link attr url = a [ style attr, href url, target "_blank" ]

-- create the subtitle span under the title
info : HN.Item -> Html
info item =
    text <| String.concat 
        [ "posted by "
        , item.by
        , " ("
        , toString item.score
        , " points) | "
        ]

-- common style properties    
font = ("font", "Helvetica")
titleSize = ("font-size", "16px")
infoSize = ("font-size", "12px")

-- common style classes
titleClass = [ titleSize, ("color", "#a52") ]
infoClass = [ infoSize, ("color", "#aaa") ]
commentClass = [ font, infoSize, ("color", "#d73") ]

-- styles for a story post
storyClass : List (String, String)
storyClass =
    [ ("margin", "0")
    , ("padding", "12px 30px")
    , ("background-color", "#fff")
    , ("overflow", "hidden")
    , ("text-overflow", "ellipsis")
    , ("white-space", "nowrap")
    , ("border-top", "1px solid #fda")
    ]