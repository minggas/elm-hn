module Model exposing (..)

import Time exposing (Time)
import Story exposing (Story)

{-| The Model is a list of stories, the view type, and loading flag. -}
type alias Model =
    { stories : List Story
    , view : View
    , loading : Bool
    }

{-| The list of items to show. -}
type View
    = Top
    | Newest
    | Show
    | Ask

{-| All the possible Cmd messages to update the model. -}
type Msg
    = Get Time
    | Refresh (List Story)
    | View View
    | None

{-| The initial model -}
init : Model
init = 
    Model [] Top False
