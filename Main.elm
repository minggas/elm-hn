module Main exposing (main)

import Html.App as App
import Task exposing (perform)
import Time exposing (Time, every, minute, now)

import HN exposing (..)
import Model exposing (..)
import Story exposing (..)
import View exposing (..)

{-| The final, aggregated model rendered to HTML. -}
main : Program Never
main = App.program
    { init = (Model.init, perform (always None) Get now)
    , subscriptions = latest
    , update = update
    , view = page
    }

{-| Every minute, get the top 30 stories from HN. -}
latest : Model -> Sub Msg
latest model =
    every minute Get

{-| Update the model. -}
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Get time -> downloadStories model time
        Refresh stories -> updateStories model stories
        View view -> updateView model view
        None -> (model, Cmd.none)

{-| Download new stories. -}
downloadStories : Model -> Time.Time -> (Model, Cmd Msg)
downloadStories model time =
    let items =
        case model.view of
            Top -> HN.top
            Newest -> HN.new
            Show -> HN.showHN
            Ask -> HN.askHN
    in
    ( { model
      | loading = True
      }
    , perform (always None) Refresh <| stories 30 time items
    )

{-| Update the model with a list of new stories (sorted by rank). -}
updateStories : Model -> List Story -> (Model, Cmd Msg)
updateStories model stories =
    ( { model
      | stories = List.sortBy (\s -> s.rank) stories
      , loading = False
      }
    , Cmd.none
    )

{-| Update the current view style and download the stories for it. -}
updateView : Model -> View -> (Model, Cmd Msg)
updateView model view =
    ( { model
      | view = view
      }
    , perform (always None) Get now
    )
