module View exposing (viewStories)

import Html exposing (..)
import Html.Attributes exposing (..)
import String

import HN exposing (..)
import Story exposing (..)

{-| Render a list of Stories to HTML. -}
viewStories : List Story -> List (Html a)
viewStories stories = List.map viewStory stories

{-| Render a single Story to HTML. -}
viewStory : Story -> Html a
viewStory story =
    div [ class "Story" ]
        [ div [ class "Title" ] [ title story.item ]
        , div [ class "Info" ] [ info story.item, comments story.item ]
        ]

{-| Render a link to an external page. -}
link : String -> String -> Html a
link url desc = a [ href url, target "_blank" ] [ text desc ]

{-| Render the title of a Story to HTML. -}
title : HN.Item -> Html a
title item = link (Maybe.withDefault (HN.comments item) item.url) item.title

{-| Render a link to the comments of a Story to HTML. -}
comments : HN.Item -> Html a
comments item =
    let n = toString <| List.length item.kids in
    link (HN.comments item) (n ++ " comments")

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
