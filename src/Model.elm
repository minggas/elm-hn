module Model exposing (..)

import Time
import Story

{-| The Model is a list of stories, the view type, and loading flag. -}
type alias Model =
    { stories : List Story.Story
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
    = Get Time.Time
    | Refresh (List Story.Story)
    | View View
    | None

{-| The initial model -}
init : Model
init = 
    Model [] Top False
