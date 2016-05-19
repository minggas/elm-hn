module Styles exposing
    ( Id(..)
    , Class(..)
    , stylesheet
    )

import Css exposing (..)

{-| CSS selector ids. -}
type Id
    = Header
    | Footer
    | Logo
    | Reader
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
    | Sep

{-| Final, rendered CSS <style> tag. -}
stylesheet : Stylesheet Id Class msg
stylesheet =
    Css.stylesheet
        [ "https://fonts.googleapis.com/css?family=Roboto+Condensed:400,700"
        , "https://fonts.googleapis.com/css?family=Roboto:400,700"
        ]
        [ bodyStyle
        , headerStyle
        , footerStyle
        , separatorStyle
        , logoStyle
        , readerStyle
        , controlsStyle
        , buttonStyle
        , enabledStyle
        , loaderStyle
        , contentStyle
        , storyStyle
        , titleStyle
        , infoStyle
        , storyLinkStyle
        , storyLinkHoverStyle
        , footerLinkStyle
        , footerLinkHoverStyle
        ]

{-| Fullscreen body styles. -}
bodyStyle : Rule Id Class
bodyStyle =
    { selectors = [ Type "body" ]
    , descriptor =
        [ ("background-color", "#333")
        , ("font-family", "'Roboto Condensed', sans-serif")
        , ("margin", "0")
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

{-| The footer styles. -}
footerStyle : Rule Id Class
footerStyle =
    { selectors = [ Id Footer ]
    , descriptor =
        [ ("margin", "0 auto")
        , ("display", "inline-block")
        , ("position", "fixed")
        , ("bottom", "0")
        , ("left", "0")
        , ("background-color", "#222")
        , ("color", "#666")
        , ("border-top", "1px solid #000")
        , ("font-size", "12px")
        , ("padding-top", "4px")
        , ("text-align", "center")
        , ("width", "100%")
        , ("height", "20px")
        ]
    }

{-| A line separator. -}
separatorStyle : Rule Id Class
separatorStyle =
    { selectors = [ Class Sep ]
    , descriptor =
        [ ("padding-right", "10px")
        , ("margin-right", "10px")
        , ("border-right", "1px solid #444") 
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

{-| Reader style. -}
readerStyle : Rule Id Class
readerStyle =
    { selectors = [ Id Reader ]
    , descriptor =
        [ ("color", "#36d" )
        , ("font-weight", "normal")
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
        [ ("margin-left", "10px")
        ]
    }

{-| The content body. -}
contentStyle : Rule Id Class
contentStyle =
    { selectors = [ Id Content ]
    , descriptor =
        [ ("margin-top", "50px")
        , ("margin-bottom", "30px")
        , ("background-color", "#333")
        ]
    }

{-| A story div style. -}
storyStyle : Rule Id Class
storyStyle =
    { selectors = [ Class Story ]
    , descriptor =
        [ ("font-family", "'Roboto', sans-serif")
        , ("margin", "0")
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
storyLinkStyle : Rule Id Class
storyLinkStyle =
    { selectors = [ Descendant (Type "a") (Class Story) ]
    , descriptor =
        [ ("color", "#d73")
        , ("text-decoration", "none")
        , ("outline", "0")
        ]
    }

{-| Link style when hovering over it. -}
storyLinkHoverStyle : Rule Id Class
storyLinkHoverStyle =
    { selectors =
        [ Pseudo [Hover] <| Descendant (Type "a") (Class Story)
        , Pseudo [Hover] <| Descendant (Type "a") (Id Footer)
        ]
    , descriptor =
        [ ("text-decoration", "underline")
        ]
    }

{-| All links. -}
footerLinkStyle : Rule Id Class
footerLinkStyle =
    { selectors = [ Descendant (Type "a") (Id Footer) ]
    , descriptor =
        [ ("color", "#36d")
        , ("text-decoration", "none")
        , ("outline", "0")
        ]
    }

{-| Link style when hovering over it. -}
footerLinkHoverStyle : Rule Id Class
footerLinkHoverStyle =
    { selectors = [ Pseudo [Hover] <| Descendant (Type "a") (Id Footer) ]
    , descriptor =
        [ ("text-decoration", "underline")
        ]
    }
    