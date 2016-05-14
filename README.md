# Hacker News Reader in Elm

While the code for the app is freely available (just clone and go...), this README is meant to be a tutorial on how to create a simple application in [Elm](http://elm-lang.org/).

![](https://raw.githubusercontent.com/massung/elm-hn/master/screenshot.PNG)

I assume you have Elm [installed](http://elm-lang.org/install/), your [favorite editor](https://code.visualstudio.com/) configured, and a basic understanding of the Elm syntax (from Haskell or ML). If not, there are other [good tutorials](https://pragmaticstudio.com/elm) introducing you to the syntax.

## Quickstart

If all you care about is the application, after cloning the repository, you'll need to download and install all the required modules that are used. This can be done on the command line with `elm package install`. Once the dependencies are installed, you can build the app with `elm make Main.elm`. The `index.html` file should have been created, and you can open it to see the app running.

## Introduction to The Elm Architecture

Okay, with the above out of the way, let's dive into making a [Hacker News](http://news.ycombinator.com/) reader from scratch...

### Create a Basic Project

First, create a new project folder. Name it anything you like, `cd` into it, and install the [core Elm package](http://package.elm-lang.org/packages/elm-lang/core/4.0.0/).

    $ elm package install

And you'll need a couple other packages, too...

    $ elm package install elm-lang/html
    $ elm package install evancz/elm-http

Finally, let's create a simple `Hello, world!` Elm file that we can build, run, and see in the browser.

```elm
module Main exposing (main)

import Html
import Html.Attributes
import Html.App

main =
    Html.text "Hello, world!"
```

Save the above file as `Main.elm`, and build is with `elm make Main.elm`. It should successfully compile an `index.html` file that you can open in your browser.

Let's improve the edit-compile-test loop, though, with Elm Reactor, while will auto-compile for us after we make changes and refresh the page.

    $ elm reactor
    Listening on http://127.0.0.1:8000/

Now, open your browser to the URL. You should see `Main.elm` in a list of files, and your package information + dependencies on the right. Simply click `Main.elm`, and Elm Reactor will recompile and open it. From here, after every change made, simply refresh the page to have it auto-recompile.

Without further adieu...

### The Elm Architecture

If you haven't yet skimmed through the [Elm Guide](http://guide.elm-lang.org/), it's worth doing. But, once you have the language basics down, the most important section is [The Elm Architecture](http://guide.elm-lang.org/architecture/index.html). In a nutshell, every Elm application is built around a Model, View, Update pattern. You define the data (Model), how it is rendered (View), and what messages can be sent to the application in order to Update it.

Currently, the `main` function merely returns an `Html.Html.Node`. This is fine if all we want is a static page. But, since we'll want a dynamic page, we need to have it - instead - return a `Html.App.Program`. Let's start with a simple skeleton that still outputs `Hello, world!`.

```elm
main : Program Never
main =
    Html.App.beginnerProgram
        { model = "Hello, world!"  
        , view = Html.text
        , update = identity
        }
```

Simple enough, but let's take stock of what's happening:

* Our Model (data) is just a string that we'll render.
* We render it by converting it to an Html text node.
* The Update function takes the existing model and returns it.

So, while *technically* we're running a "dynamic" `Html.App.Program`, it's not going to do anything special.

### A Closer Look...

While `Html.App.beginnerProgram` wraps some things for us, it doesn't allow us to see what's really going on. So, let's peel back a layer and see where it leads...

```elm
import Platform.Cmd as Cmd
import Platform.Sub as Sub

main : Program Never
main =
    Html.App.program
        { init = ( "Hello, world!", Cmd.none )
        , view = Html.text
        , update = \msg model -> ( model, Cmd.none )
        , subscriptions = \model -> Sub.none
        }
```

Okay, a lot has changed, but the output is the same...

First, notice that we've imported a couple new modules: `Platform.Cmd` and `Platform.Sub`. These two modules are at the very *heart* of The Elm Architecture's application Update pattern. More on that in a bit...

Next, instead of passing in `model`, we pass in `init`, which consists of both the `Model` and an initial `Cmd` (for which we don't want to use yet).

Also, our `update` function has changed its signature as well. Not only does it take a mysterious `msg` parameter (which we're currently ignoring), but it also returns the `model` and a `Cmd`, just like in `init`.

Finally, there's a `subscriptions`. We'll get back to those later, but for now, we don't want any.

### So What is `Cmd`?

The first part of The Elm Architecture that you need to fully understand is the `Cmd` type. It is [defined](http://package.elm-lang.org/packages/elm-lang/core/4.0.0/Platform-Cmd#Cmd) as...

```elm
type Cmd msg
```

What's important to know about `Cmd` is that it is simply a type wrapper for The Elm Architecture to preserve type safety. Internally, TEM (the Elm Architecture) doesn't know what type you'll use for your update messages, but it will need to pass them around safely. It does this by wrapping it with `Cmd`.

To put this into practice, let's create an update message for our application that will change the message being displayed to a different string.

```elm
type alias Model = String
type alias Msg = String
```

Next, let's change our `main` definition. First, let's refactor the `update` function. Since our `model` is a `String` and so is our `Msg`, we can just replace the existing `model` with the incoming `Msg`.

```elm
main =
    Html.App.program
        { init = ( "Hello, world!", Cmd.none )
        , view = Html.text
        , update = update
        , subscriptions = \model -> Sub.none
        }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    (msg, Cmd.none)
```

Finally, we need to create a `Cmd` that TEM can receive, unbox, and pass the `Msg` to our `update` function. In order to create a `Cmd`, we need to perform a [Task](http://package.elm-lang.org/packages/elm-lang/core/4.0.0/Task). So, let's create a `Task` that will send `Cmd Msg` to TEM, which will pass on the `Msg` to our `update` function...

```elm
import Task

type alias Model = String
type alias Msg = String

main : Program Never
main =
    Html.App.program
        { init = ( "Hello, world!", changeModel "It changed!" )
        , view = Html.text
        , update = update
        , subscriptions = \model -> Sub.none
        }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    ( msg, Cmd.none )

changeModel : Msg -> Cmd Msg
changeModel msg =
    let onError = identity in
    let onSuccess = identity in
    Task.perform onError onSuccess (Task.succeed msg)
```

Now, in the `init` of our application, we create an initial `Cmd` for our `Msg` so TEM can properly route it to our `update` function, which changes the `Model`. And, when we run the app, we can see that it works.

### More Complex Messages

One part glossed over above were the transform functions `onError` and `onSuccess`. For the example, they were both just set to `identity`. This was possible, because the task was generating a `String`, which also happens to be the same data type as our `Msg`. But, usually that won't be the case. Let's modify our `Msg` data type so that instead of a `String`, let's make it a `Maybe`.

```elm
type alias Msg = Maybe String
```

Now, our `update` function needs to understand that *maybe* (ha!) the `Msg` doesn't have anything for us...

```elm
update msg model =
    case msg of
        Just newModel -> ( newModel, Cmd.none )
        Nothing -> ( model, Cmd.none )
```

Last, our `changeModel` function needs to take a `String` and transform the result of the `Task` into a `Msg`.

```elm
changeModel : String -> Cmd Msg
changeModel s =
    Task.perform (\_ -> Nothing) Just (Task.succeed s)
```

Excellent! If we run, we should see everything still works.

Just for kicks, let's make sure it does the right thing if the task fails. We'll do this by creating a `Task` that we know will fail.

```elm
    Task.perform (\_ -> Nothing) Just (Task.fail 0)
```

And, just as it should, the `model` doesn't change.

### Quick Summary

Let's recap what we've discovered...

* We initial our program with an initial `Model` and `Cmd`
* A `Cmd` is a type wrapper so TEM can (safely) route our own `Msg` values to `update`
* `Cmd`s can be created by performing tasks
* Tasks can fail or succeed
* The program must transform task results into `Msg` values

### Subscriptions

Besides `Cmd`, the only other way of getting TEM to send a `Msg` to our `update` function is with a `Sub`scription to an event. There are many different events that can be subscribed to (mouse, keyboard, time, ...). And these are all done via the `subscriptions` function of your program.

Every time your `model` is updated, TEM calls the `subscriptions` function to ask the application for a list of subscriptions it should listen to, and `update` with.

As an example, let's create a simple subscription (`Sub`) that updates our `Model` with the current time about every second.

```elm
import Time

main : Program Never
main =
    Html.App.program
        { init = ( "Hello, world!", changeModel "It changed!" )
        , view = Html.text
        , update = update
        , subscriptions = subscriptions
        }

subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every Time.second (Just << toString)
```

From these modifications, we can see that based on the `model` (ignored in this instance), we create a subscription to an event (`Time.every Time.second`) and give it a function (`Just << toString`) that can convert the event parameter (time) into a `Msg`. The `Msg` is boxed into a `Sub` (just like a `Cmd`), which TEM can then route to the `update` function.

*Note: if you have many events you'd like to subscribe to, use [`Sub.batch`](http://package.elm-lang.org/packages/elm-lang/core/4.0.0/Platform-Sub#batch) to aggregate multiple subscriptions into a single subscription.*

### Summarizing The Elm Architecture

* TEM is *the* method of building applications in Elm
* It wraps your program in the `Model`, `View`, `Update` pattern
* You initialize the program with the `Model`
* You provide the program with a function to render the `Model` (the `View`)
* You define a message type that is used to `Update` the `Model`
* The messages are wrapped - for type safety - into `Cmd` and `Sub`
* A `Cmd` is the result of a `Task`
* A `Sub` is the result of an event subscription
* You transform the results of task and subscriptions into your message type
* The `Cmd` and `Sub` are used by TEM to route your message to the `Update`

That's it!

It's very important that you understand this moving forward. Once it "clicks", Elm is wonderful to use.

## Putting it All Together

Next is a walk-through of using TEM to create a very simple Hacker News reader. It won't have all the features of the reader in this repo, but it will get you started and you should be able to use the source code in this repository to take your version to the next level.

Coming soon... 