module Css exposing
    ( Css
    , Sel (..)
    , Pseudo (..)
    , Rule
    , Descriptor
    , css
    )

import Html exposing (..)
import Html.Attributes exposing (id, class)
import String exposing (concat, join)

{-| Compiled CSS styles -}
type alias Css id cls msg =
    { node : Html msg
    , id : id -> Attribute msg
    , class : cls -> Attribute msg
    }

{-| A basic CSS selector. -}
type Sel id cls
    = Element String
    | Id id
    | Class cls
    | Pseudo (List Pseudo) (Sel id cls)

{-| Pseudo CSS selectors and elements. -}
type Pseudo
    = Any
    | Default
    | Link
    | Visited
    | Hover
    | Active
    | Focus
    | Target
    | Enabled
    | Disabled
    | Checked
    | Indeterminate
    | Invalid
    | Valid
    | Fullscreen
    | Root
    | Scope
    | FirstChild
    | LastChild
    | NthChild Int
    | NthLastChild Int
    | NthOfType String
    | NthLastOfType String
    | FirstOfType
    | LastOfType
    | OnlyOfType
    | Empty
    | Left
    | Right
    | Lang String
    | Dir String
    | FirstLetter
    | FirstLine
    | Before
    | After
    | Selection
    | Backdrop

{-| Key/value style descriptors. -}
type alias Descriptor = List (String, String)

{-| A selector/descriptor pair. -}
type alias Rule id cls =
    { selector : List (Sel id cls)
    , descriptor : Descriptor
    }

{-| Render a pseudo selector/element to a string. -}
pseudo : Pseudo -> String
pseudo p = 
    case p of
        Any -> ":any"
        Default -> ":default"
        Link -> ":link"
        Visited -> ":visited"
        Hover -> ":hover"
        Active -> ":active"
        Focus -> ":focus"
        Target -> ":target"
        Enabled -> ":enabled"
        Disabled -> ":disabled"
        Checked -> ":checked"
        Indeterminate -> ":indeterminate"
        Invalid -> ":invalid"
        Valid -> ":valid"
        Fullscreen -> ":fullscreen"
        Root -> ":root"
        Scope -> ":scope"
        FirstChild -> ":first-child"
        LastChild -> ":last-child"
        NthChild n -> ":nth-child(" ++ (toString n) ++ ")"
        NthLastChild n -> ":nth-last-child(" ++ (toString n) ++ ")"
        NthOfType s -> ":nth-of-type(" ++ s ++ ")"
        NthLastOfType s -> ":nth-last-of-type(" ++ s ++ ")"
        FirstOfType -> ":first-of-type"
        LastOfType -> ":last-of-type"
        OnlyOfType -> ":only-of-type"
        Lang s -> ":lang(" ++ s ++ ")"
        Dir s -> ":dir(" ++ s ++ ")"
        Empty -> ":empty"
        Left -> ":left"
        Right -> ":right"
        FirstLetter -> "::first-letter"
        FirstLine -> "::first-line"
        Before -> "::before"
        After -> "::after"
        Selection -> "::selection"
        Backdrop -> "::backdrop"

{-| Render a selector to a string. -}
sel : List (Sel id cls) -> String
sel =
    let sel' selector =
        case selector of
            Element node -> node
            Id id -> "#" ++ (toString id)
            Class cls -> "." ++ (toString cls)
            Pseudo ps s -> concat <| sel' s :: (List.map pseudo ps)
    in
    join "," << List.map sel'

{-| Render a descriptor to a string. -}
desc : Descriptor -> String
desc = concat << List.map (\(k, v) -> concat [k, ":", v, ";"])

{-| Render a style (selector and descriptor) to a string. -}
style : Rule id class -> String
style s = concat [ sel s.selector, "{", desc s.descriptor, "}" ]

{-| Returns a compiled CSS object with style node and attribute builders. -}
css : List (Rule id cls) -> Css id cls msg
css styles =
    { node = node "style" [] [ text <| concat <| List.map style styles ]
    , id = id << toString
    , class = class << toString
    }
