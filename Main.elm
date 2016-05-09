module Main where

import Html
import Http
import Task exposing (andThen)
import Time exposing (every, minute)

import HN exposing (..)
import Story exposing (..)
import View exposing (..)

{-| The Model is just a list of stories. -}
type alias Model =
    { stories : List Story
    }

{-| Interface and mailbox signals combine into Actions. -}
type Action
    = Refresh (List Story)

{-| The final, aggregated model transformed to HTML. -}
main : Signal Html.Html
main = 
    let stories = Signal.foldp update (Model []) aggregate in
    Signal.map (view << viewStories << rankedStories) stories

{-| Wrap a list of rendered Stories into a parent HTML element. -}
view : List Html.Html -> Html.Html
view = Html.body []

{-| Every minute, get the top 30 stories from HN. -}
port latest : Signal (Task.Task Http.Error ())
port latest = Signal.map (HN.topStories 30) <| every minute

{-| Create a Refresh action each time the latest stories change. -}
aggregate : Signal Action
aggregate = Signal.map Refresh stories

{-| Sort all the stories in the model based on their rank. -}
rankedStories : Model -> List Story
rankedStories model = List.sortBy (\s -> s.rank) model.stories

{-| Updates the current Model given an Action. -}
update : Action -> Model -> Model
update action model =
    case action of
        Refresh stories -> { model | stories = stories }
