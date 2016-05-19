module View exposing (page)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String

import Css exposing (Stylesheet)
import HN exposing (..)
import Model exposing (..)
import Story exposing (..)
import Styles exposing (..)

{-| Wrap a list of rendered Stories into a parent HTML element. -}
page : Model -> Html Msg
page model =
    div []
        [ stylesheet.node
        , header model
        , content model
        , footer model
        ]

{-| Renders the title header and controls. -}
header : Model -> Html Msg
header model =
    div [ stylesheet.id Header ]
        [ span [ stylesheet.id Logo ] 
            [ img [ src "images/icon.png", height 22 ] []
            , text " "
            , span [ stylesheet.class Sep ] [ text "Hacker News" ] 
            , span [ stylesheet.id Reader ] [ text "reader" ]
            , loader model
            ]
        , span [ stylesheet.id Controls ]
            [ button model Top "Top Stories"
            , span [ stylesheet.class Sep ] []
            , button model Newest "New"
            , span [ stylesheet.class Sep ] []
            , button model Show "Show"
            , span [ stylesheet.class Sep ] []
            , button model Ask "Ask"
            ]
        ]

{-| Render the footer. -}
footer : Model -> Html Msg
footer model =
    div [ stylesheet.id Footer ]
        [ span [] [ text "Copyright (c) Jeffrey Massung " ]
        , link "http://twitter.com/stymiedcoder" "@stymiedcoder"
        , span [ stylesheet.class Sep ] []
        , span [] [ text "Powered by " ]
        , link "http://elm-lang.org" "Elm"
        , span [ stylesheet.class Sep ] []
        , span [] [ text "Source available on " ]
        , link "http://github.com/massung/elm-hn" "GitHub"
        ]

{-| Render the main content area. -}
content : Model -> Html Msg
content model =
    div [ stylesheet.id Content ] <| viewStories stylesheet model.stories

{-| If we're currently updating the story list, indicate with a gif. -}
loader : Model -> Html Msg
loader model =
    let notification =
        if model.loading then
            [ img [ src "images/loader.gif" ] [] ]
        else
            []
    in
    span [ stylesheet.id Loader ] notification

{-| Renders a control button. -}
button : Model -> View -> String -> Html Msg
button model view title =
    if model.view == view then
        b [ stylesheet.class Styles.Enabled ] [ text title ]
    else
        a [ onClick (View view), href "#" ] [ text title ]

{-| Render a list of Stories to HTML. -}
viewStories : Stylesheet x Class Msg -> List Story -> List (Html Msg)
viewStories stylesheet stories =
    List.map (viewStory stylesheet) stories

{-| Render a single Story to HTML. -}
viewStory : Stylesheet x Class Msg -> Story -> Html Msg
viewStory stylesheet story =
    div [ stylesheet.class Styles.Story ]
        [ div [ stylesheet.class Title ] [ title story.item ]
        , div [ stylesheet.class Info ] [ info story.item, comments story.item ]
        ]

{-| Render a link to an external page. -}
link : String -> String -> Html Msg
link url desc =
    a [ href url, target "_blank" ] [ text desc ]

{-| Render the title of a Story to HTML. -}
title : HN.Item -> Html Msg
title item =
    link (Maybe.withDefault (HN.comments item) item.url) item.title

{-| Render a link to the comments of a Story to HTML. -}
comments : HN.Item -> Html Msg
comments item =
    let n = toString <| List.length item.kids in
    link (HN.comments item) (n ++ " comments")

{-| Render information about a HN Item. -}
info : HN.Item -> Html Msg
info item =
    text <| String.concat 
        [ "posted by "
        , item.by
        , " ("
        , toString item.score
        , " points) | "
        ]
