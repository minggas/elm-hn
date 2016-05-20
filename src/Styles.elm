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
        [ body
        , header
        , footer
        , separator
        , logo
        , reader
        , controls
        , button
        , enabled
        , loader
        , content
        , story
        , title
        , info
        , storyLink
        , storyLinkHover
        , footerLink
        , footerLinkHover
        ]

{-| Fullscreen body styles. -}
body : Rule Id Class
body =
    { selectors = [ Type "body" ]
    , descriptor =
        [ ("background-color", "#333")
        , ("font-family", "'Roboto Condensed', sans-serif")
        , ("margin", "0")
        ]
    }

{-| The header styles. -}
header : Rule Id Class
header =
    { selectors = [ Id Header ]
    , descriptor =
        [ ("margin", "0")
        , ("display", "inline-block")
        , ("font-size", "larger")
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
footer : Rule Id Class
footer =
    { selectors = [ Id Footer ]
    , descriptor =
        [ ("margin", "0 auto")
        , ("background-color", "#222")
        , ("color", "#666")
        , ("border-top", "1px solid #000")
        , ("font-size", "smaller")
        , ("padding-top", "4px")
        , ("text-align", "center")
        , ("width", "100%")
        , ("height", "20px")
        ]
    }

{-| A line separator. -}
separator : Rule Id Class
separator =
    { selectors = [ Class Sep ]
    , descriptor =
        [ ("padding-right", "10px")
        , ("margin-right", "10px")
        , ("border-right", "1px solid #444") 
        ]
    }

{-| Page title information. -}
logo : Rule Id Class
logo =
    { selectors = [ Id Logo ]
    , descriptor =
        [ ("font-size", "larger")
        , ("position", "relative")
        , ("left", "30px")
        , ("top", "14px")
        ]
    }

{-| Reader style. -}
reader : Rule Id Class
reader =
    { selectors = [ Id Reader ]
    , descriptor =
        [ ("color", "#36d" )
        , ("font-weight", "normal")
        ]
    }
    
{-| User options section. -}
controls : Rule Id Class
controls =
    { selectors = [ Id Controls ]
    , descriptor =
        [ ("font-weight", "200")
        , ("position", "fixed")
        , ("right", "30px")
        , ("top", "16px")
        ]
    }

{-| Control links. -}
button : Rule Id Class
button =
    { selectors = [ Descendant (Type "a") (Id Header) ]
    , descriptor =
        [ ("color", "#aaa" )
        , ("text-decoration", "none")
        , ("outline", "0")
        ]
    }

{-| Toggle options for user. -}
enabled : Rule Id Class
enabled =
    { selectors = [ Class Enabled ]
    , descriptor =
        [ ("background-color", "#36d")
        , ("font-weight", "bold")
        , ("border-radius", "4px")
        , ("padding", "2px 6px")
        ]
    }

{-| Loading gif. -}
loader : Rule Id Class
loader =
    { selectors = [ Id Loader ]
    , descriptor =
        [ ("margin-left", "10px")
        ]
    }

{-| The content body. -}
content : Rule Id Class
content =
    { selectors = [ Id Content ]
    , descriptor =
        [ ("margin-top", "50px")
        , ("background-color", "#333")
        ]
    }

{-| A story div style. -}
story : Rule Id Class
story =
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
title : Rule Id Class
title =
    { selectors = [ Class Title ]
    , descriptor =
        [ ("font-size", "medium")
        , ("font-weight", "bold")
        , ("margin-bottom", "6px")
        ]
    }

{-| The posted by span. -}
info : Rule Id Class
info =
    { selectors = [ Class Info ]
    , descriptor =
        [ ("font-size", "smaller")
        , ("color", "#aaa")
        ]
    }

{-| All links. -}
storyLink : Rule Id Class
storyLink =
    { selectors = [ Descendant (Type "a") (Class Story) ]
    , descriptor =
        [ ("color", "#d73")
        , ("text-decoration", "none")
        , ("outline", "0")
        ]
    }

{-| Link style when hovering over it. -}
storyLinkHover : Rule Id Class
storyLinkHover =
    { selectors =
        [ Pseudo [Hover] <| Descendant (Type "a") (Class Story)
        , Pseudo [Hover] <| Descendant (Type "a") (Id Footer)
        ]
    , descriptor =
        [ ("text-decoration", "underline")
        ]
    }

{-| All links. -}
footerLink : Rule Id Class
footerLink =
    { selectors = [ Descendant (Type "a") (Id Footer) ]
    , descriptor =
        [ ("color", "#36d")
        , ("text-decoration", "none")
        , ("outline", "0")
        ]
    }

{-| Link style when hovering over it. -}
footerLinkHover : Rule Id Class
footerLinkHover =
    { selectors = [ Pseudo [Hover] <| Descendant (Type "a") (Id Footer) ]
    , descriptor =
        [ ("text-decoration", "underline")
        ]
    }
    