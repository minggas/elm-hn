module Styles exposing
    ( Id(..)
    , Class(..)
    , stylesheet
    )

import Css exposing (..)

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
    | Enabled

{-| Final, rendered CSS <style> tag. -}
stylesheet : Stylesheet Id Class msg
stylesheet =
    css
        [ "//fonts.googleapis.com/css?family=Droid+Sans:400,700" ]
        [ bodyStyle
        , headerStyle
        , logoStyle
        , controlsStyle
        , buttonStyle
        , enabledStyle
        , loaderStyle
        , contentStyle
        , storyStyle
        , titleStyle
        , infoStyle
        , linkStyle
        , linkHoverStyle
        ]

{-| Fullscreen body styles. -}
bodyStyle : Rule Id Class
bodyStyle =
    { selectors = [ Type "body" ]
    , descriptor =
        [ ("background-color", "#333")
        , ("font-family", "Droid Sans, sans-serif")
        ]
    }
    
{-| The header styles. -}
headerStyle : Rule Id Class
headerStyle =
    { selectors = [ Id Header ]
    , descriptor =
        [ ("margin", "0")
        , ("display", "inline-block")
        , ("position", "fixed")
        , ("top", "0")
        , ("left", "0")
        , ("width", "100%")
        , ("height", "50px")
        , ("overflow", "hidden")
        , ("background-color", "#222")
        , ("color", "#ddd")
        , ("font-weight", "bold")
        , ("border-bottom", "1px solid #000")
        ]
    }

{-| Page title information. -}
logoStyle : Rule Id Class
logoStyle =
    { selectors = [ Id Logo ]
    , descriptor =
        [ ("font-size", "22px")
        , ("position", "relative")
        , ("left", "30px")
        , ("top", "14px")
        ]
    }
    
{-| User options section. -}
controlsStyle : Rule Id Class
controlsStyle =
    { selectors = [ Id Controls ]
    , descriptor =
        [ ("font-size", "18px")
        , ("font-weight", "200")
        , ("position", "fixed")
        , ("right", "30px")
        , ("top", "16px")
        ]
    }

{-| Control links. -}
buttonStyle : Rule Id Class
buttonStyle =
    { selectors = [ Descendant (Type "a") (Id Header) ]
    , descriptor =
        [ ("color", "#aaa" )
        , ("text-decoration", "none")
        , ("outline", "0")
        ]
    }

{-| Toggle options for user. -}
enabledStyle : Rule Id Class
enabledStyle =
    { selectors = [ Class Enabled ]
    , descriptor =
        [ ("background-color", "#36d")
        , ("font-weight", "bold")
        , ("border-radius", "4px")
        , ("padding", "2px 6px")
        ]
    }

{-| Loading gif. -}
loaderStyle : Rule Id Class
loaderStyle =
    { selectors = [ Id Loader ]
    , descriptor =
        [ ("position", "fixed")
        , ("right", "30px")
        , ("bottom", "10px")
        ]
    }

{-| The content body. -}
contentStyle : Rule Id Class
contentStyle =
    { selectors = [ Id Content ]
    , descriptor =
        [ ("margin-top", "50px")
        , ("background-color", "#333")
        ]
    }

{-| A story div style. -}
storyStyle : Rule Id Class
storyStyle =
    { selectors = [ Class Story ]
    , descriptor =
        [ ("margin", "0")
        , ("padding", "12px 30px")
        , ("background-color", "#333")
        , ("color", "#ddd")
        , ("border-top", "1px solid #444")
        ]
    }

{-| The title of the story. -}
titleStyle : Rule Id Class
titleStyle =
    { selectors = [ Class Title ]
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
infoStyle : Rule Id Class
infoStyle =
    { selectors = [ Class Info ]
    , descriptor =
        [ ("font-size", "12px")
        , ("color", "#aaa")
        ]
    }

{-| All links. -}
linkStyle : Rule Id Class
linkStyle =
    { selectors = [ Descendant (Type "a") (Class Story) ]
    , descriptor =
        [ ("color", "#d73")
        , ("text-decoration", "none")
        , ("outline", "0")
        ]
    }

{-| Link style when hovering over it. -}
linkHoverStyle : Rule Id Class
linkHoverStyle =
    { selectors = [ Pseudo [Hover] <| Descendant (Type "a") (Class Story) ]
    , descriptor =
        [ ("text-decoration", "underline")
        ]
    }