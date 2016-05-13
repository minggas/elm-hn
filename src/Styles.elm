module Styles exposing
    ( Id(..)
    , Class(..)
    , css
    )

import Css

{-| CSS selector ids. -}
type Id
    = Header
    | Logo
    | Controls
    | Loader
    | Content

{-| CSS selector classes. -}
type Class
    = Story
    | Title
    | Info
    | Comment

{-| Final, rendered CSS <style> tag. -}
css : Css.Css Id Class msg
css = Css.css styles

{-| All the styles in the CSS. -}
styles : List (Css.Rule Id Class)
styles = 
    [ bodyStyle
    , headerStyle
    , logoStyle
    , controlsStyle
    , loaderStyle
    , contentStyle
    , storyStyle
    , titleStyle
    , infoStyle
    , linkStyle
    , linkHoverStyle
    ]

{-| Fullscreen body styles. -}
bodyStyle : Css.Rule Id Class
bodyStyle =
    { selector = [ Css.Element "body" ]
    , descriptor =
        [ ("background-color", "#333")
        , ("font-family", "Droid Sans, sans-serif")
        ]
    }
    
{-| The header styles. -}
headerStyle : Css.Rule Id Class
headerStyle =
    { selector = [ Css.Id Header ]
    , descriptor =
        [ ("margin", "0")
        , ("display", "inline-block")
        , ("position", "fixed")
        , ("top", "0")
        , ("left", "0")
        , ("width", "100%")
        , ("height", "50px")
        , ("overflow", "hidden")
        , ("background-color", "#63d")
        , ("color", "#fff")
        , ("font-weight", "bold")
        ]
    }

{-| Page title information. -}
logoStyle : Css.Rule Id Class
logoStyle =
    { selector = [ Css.Id Logo ]
    , descriptor =
        [ ("font-size", "22px")
        , ("position", "relative")
        , ("left", "30px")
        , ("top", "14px")
        ]
    }

{-| Toggle options for user. -}
controlsStyle : Css.Rule Id Class
controlsStyle =
    { selector = [ Css.Id Controls ]
    , descriptor =
        [ ("font-family", "Consolas, monospace")
        , ("font-size", "18px")
        , ("position", "fixed")
        , ("right", "30px")
        , ("top", "16px")
        ]
    }

{-| Loading gif. -}
loaderStyle : Css.Rule Id Class
loaderStyle =
    { selector = [ Css.Id Loader ]
    , descriptor =
        [ ("position", "fixed")
        , ("right", "30px")
        , ("bottom", "10px")
        ]
    }

{-| The content body. -}
contentStyle : Css.Rule Id Class
contentStyle =
    { selector = [ Css.Id Content ]
    , descriptor =
        [ ("margin-top", "50px")
        , ("background-color", "#333")
        ]
    }

{-| A story div style. -}
storyStyle : Css.Rule Id Class
storyStyle =
    { selector = [ Css.Class Story ]
    , descriptor =
        [ ("margin", "0")
        , ("padding", "12px 30px")
        , ("background-color", "#333")
        , ("color", "#ddd")
        , ("border-top", "1px solid #444")
        ]
    }

{-| The title of the story. -}
titleStyle : Css.Rule Id Class
titleStyle =
    { selector = [ Css.Class Title ]
    , descriptor =
        [ ("font-size", "16px")
        , ("font-weight", "bold")
        , ("margin-bottom", "6px")
        , ("overflow", "hidden")
        , ("text-overflow", "ellipsis")
        , ("white-space", "nowrap")
        ]
    }

{-| The posted by span. -}
infoStyle : Css.Rule Id Class
infoStyle =
    { selector = [ Css.Class Info ]
    , descriptor =
        [ ("font-size", "12px")
        , ("color", "#aaa")
        ]
    }

{-| All links. -}
linkStyle : Css.Rule Id Class
linkStyle =
    { selector = [ Css.Element "a" ]
    , descriptor =
        [ ("color", "#d73")
        , ("text-decoration", "none")
        ]
    }

{-| Link style when hovering over it. -}
linkHoverStyle : Css.Rule Id Class
linkHoverStyle =
    { selector = [ Css.Pseudo [ Css.Hover ] (Css.Element "a") ]
    , descriptor =
        [ ("text-decoration", "underline")
        ]
    }