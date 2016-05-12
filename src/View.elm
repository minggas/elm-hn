module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import String

import HN exposing (..)
import Story exposing (..)
import Styles exposing (..)

{-| Render a list of Stories to HTML. -}
viewStories : List Story -> List (Html a)
viewStories stories = List.map viewStory stories

{-| Render a single Story to HTML. -}
viewStory : Story -> Html a
viewStory story =
    div [ style Styles.storyClass ]
        [ title story.item
        , br [] []
        , span [ style infoClass ] [ info story.item ]
        , comments story.item
        ]

{-| Render the title of a Story to HTML. -}
title : HN.Item -> Html a
title item = link titleClass (HN.link item) [ text item.title ]

{-| Render a link to the comments of a Story to HTML. -}
comments : HN.Item -> Html a
comments item =
    link commentClass (HN.comments item)
        [ text <| (toString <| List.length item.kids) ++ " comments"
        ]

{-| Render a link to an external page. -}
link : List (String, String) -> String -> List (Html a) -> Html a
link attr url = a [ style attr, href url, target "_blank" ]

{-| Render information about a HN Item. -}
info : HN.Item -> Html a
info item =
    text <| String.concat 
        [ "posted by "
        , item.by
        , " ("
        , toString item.score
        , " points) | "
        ]
