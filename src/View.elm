module View exposing (viewStories)

import Html exposing (..)
import Html.Attributes exposing (..)
import String

import Css exposing (..)
import HN exposing (..)
import Story exposing (..)
import Styles exposing (..)

{-| Render a list of Stories to HTML. -}
viewStories : Css x Class msg -> List Story -> List (Html msg)
viewStories css stories = List.map (viewStory css) stories

{-| Render a single Story to HTML. -}
viewStory : Css x Class msg -> Story -> Html msg
viewStory css story =
    div [ class "Story" ]
        [ div [ css.class Title ] [ title story.item ]
        , div [ css.class Info ] [ info story.item, comments story.item ]
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
