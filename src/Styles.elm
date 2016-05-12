module Styles exposing (..)

-- Shared styles.
font = ("font", "Helvetica")
titleSize = ("font-size", "16px")
infoSize = ("font-size", "12px")

-- Common style lists.
titleClass = [ titleSize, ("color", "#a52") ]
infoClass = [ infoSize, ("color", "#aaa") ]
commentClass = [ font, infoSize, ("color", "#d73") ]

-- Styles for a Story.
storyClass =
    [ ("margin", "0")
    , ("padding", "12px 30px")
    , ("background-color", "#fff")
    , ("overflow", "hidden")
    , ("text-overflow", "ellipsis")
    , ("white-space", "nowrap")
    , ("border-top", "1px solid #eee")
    ]