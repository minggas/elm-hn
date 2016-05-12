module Css exposing
    ( Sel (..)
    , Style
    , Descriptor
    , css
    , id
    , class
    )

import Html exposing (..)
import Html.Attributes
import String exposing (concat, join)

{-| A basic CSS selector. -}
type Sel id cls
    = Element String
    | Id id
    | Class cls

{-| Key/value style descriptors. -}
type alias Descriptor = List (String, String)

{-| A selector/descriptor pair. -}
type alias Style id cls =
    { selector : Sel id cls
    , descriptor : Descriptor
    }

{-| Render a selector to a string. -}
sel : Sel id cls -> String
sel selector =
    case selector of
        Element node -> node
        Id id -> "#" ++ (toString id)
        Class cls -> "." ++ (toString cls)

{-| Render a descriptor to a string. -}
desc : Descriptor -> String
desc = concat << List.map (\(k, v) -> concat [k, ":", v, ";"])

{-| Render a style (selector and descriptor) to a string. -}
style : Style id class -> String
style s = concat [ sel s.selector, "{", desc s.descriptor, "}" ]

{-| Render a list of styles to an Html node. -}
css : List (Style id class) -> Html a
css styles = Html.node "style" [] <| [ text <| concat <| List.map style styles ]

{-| Create an id attribute. -}
id : String -> Html.Attribute a
id = Html.Attributes.id

{-| Create a class attribute. -}
class : List String -> Html.Attribute a
class = Html.Attributes.class << join " " 
