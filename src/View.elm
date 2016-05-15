module View exposing (page)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import String

import Css exposing (..)
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
        , loader model
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
            ]
        , span [ stylesheet.id Controls ]
            [ button model Top "Top Stories"
            , text " • "
            , button model Newest "New"
            , text " • "
            , button model Show "Show"
            , text " • "
            , button model Ask "Ask"
            ]
        ]

{-| Render the main content area. -}
content : Model -> Html Msg
content model =
    div [ stylesheet.id Content ] <| viewStories stylesheet model.stories

{-| If we're currently updating the story list, indicate with a gif. -}
loader : Model -> Html Msg
loader model =
    let notification =
        if model.loading then [ img [ src "loader.gif" ] [] ] else []
    in
    div [ stylesheet.id Loader ] notification

{-| Renders a control button. -}
button : Model -> View -> String -> Html Msg
button model view title =
    if model.view == view then
        b [ stylesheet.class Styles.Enabled ] [ text title ]
    else
        a [ onClick (View view), href "#" ] [ text title ]

{-| Render a list of Stories to HTML. -}
viewStories : Stylesheet x Class msg -> List Story -> List (Html msg)
viewStories css stories =
    List.map (viewStory css) stories

{-| Render a single Story to HTML. -}
viewStory : Stylesheet x Class msg -> Story -> Html msg
viewStory css story =
    div [ css.class Styles.Story ]
        [ div [ css.class Title ] [ title story.item ]
        , div [ css.class Info ] [ info story.item, comments story.item ]
        ]

{-| Render a link to an external page. -}
link : String -> String -> Html a
link url desc =
    a [ href url, target "_blank" ] [ text desc ]

{-| Render the title of a Story to HTML. -}
title : HN.Item -> Html a
title item =
    link (Maybe.withDefault (HN.comments item) item.url) item.title

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
