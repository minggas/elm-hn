# Hacker News Reader in Elm

While the code for the app is freely available (just clone and go...), this README is meant to be a tutorial on how to create a simple application in [Elm](http://elm-lang.org/).

![](https://raw.githubusercontent.com/massung/elm-hn/master/screenshot.PNG)

*Note: The icon for the app was taken from [The Pictographers](https://www.iconfinder.com/bluewolfski), who make some pretty slick icons!*

I assume you have Elm [installed](http://elm-lang.org/install/), your [favorite editor](https://code.visualstudio.com/) configured, and a basic understanding of the Elm syntax (from Haskell or ML). If not, there are other [good tutorials](https://pragmaticstudio.com/elm) introducing you to the syntax.

## Quickstart

If all you care about is the application, after cloning the repository, you'll need to download and install all the required modules that are used. This can be done on the command line with `elm package install`. Once the dependencies are installed, you can build the app with `elm make Main.elm --output=elm.js`. The `index.html` can then be opened and away you go. If you have [Electron](http://package.elm-lang.org/packages/elm-lang/core/4.0.0/) installed, you can also launch it that way: `electron .`.

## Introduction to The Elm Architecture

Okay, with the above out of the way, let's dive into making a [Hacker News](http://news.ycombinator.com/) reader from scratch...

### Create a Basic Project

First, create a new project folder. Name it anything you like, `cd` into it, and install the [core Elm package](http://package.elm-lang.org/packages/elm-lang/core/4.0.0/).

    $ elm package install

And you'll need a couple other packages, too...

    $ elm package install elm-lang/html

Finally, let's create a simple `Hello, world!` Elm file that we can build, run, and see in the browser.

```elm
module Main exposing (main)

import Html
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
        { init = ("Hello, world!", Cmd.none)
        , view = Html.text
        , update = update
        , subscriptions = always Sub.none
        }
        
update : msg -> Model -> (Model, Cmd msg)
update msg model =
    (model, Cmd.none)
```

Okay, a lot has changed, but the output is the same...

First, notice that we've imported a couple new modules: `Platform.Cmd` and `Platform.Sub`. These two modules are at the very *heart* of The Elm Architecture's application Update pattern. More on that in a bit...

Next, instead of passing in `model`, we pass in `init`, which consists of both the `Model` and an initial `Cmd` (for which we don't want to use yet).

Also, our `update` function (which we've refactored out) has changed its signature as well. Not only does it take a mysterious `msg` parameter, which we're currently ignoring, but it also returns the `model` and a `Cmd`, just like the `init`.

Finally, there's a `subscriptions`. We'll get back to those later, but for now, we don't want any.

### So What is `Cmd`?

The first part of The Elm Architecture that you need to fully understand is the `Cmd` type. It is [defined](http://package.elm-lang.org/packages/elm-lang/core/4.0.0/Platform-Cmd#Cmd) as...

```elm
type Cmd msg
```

What's important to know about `Cmd` is that it is simply a type wrapper for The Elm Architecture to preserve type safety. Internally, TEA (the Elm Architecture) doesn't know what type you'll use for your update messages, but it will need to pass them around safely. It does this by wrapping it with `Cmd`.

To put this into practice, let's define our `Msg` type to just be a `String`. Whenever our application receives a `Msg`, it updates the current model to the value of the `Msg`.

```elm
type alias Model = String
type alias Msg = String
```

Next, let's change the definition of our `update` function to properly accept our new `Msg` type, and update the model appropriately.

```elm
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    (msg, Cmd.none)
```

Finally, we need to create a `Cmd` that TEA (The Elm Architecture) can receive, unbox, and pass the `Msg` to our `update` function. To do this, we `perform` a [Task](http://package.elm-lang.org/packages/elm-lang/core/4.0.0/Task). All tasks in Elm are executed in the background, and the resulting `Cmd` is routed to our application when done.

Here's what our current program looks like - in full - now...

```elm
module Main exposing (main)

import Html
import Html.App

import Platform.Cmd as Cmd
import Platform.Sub as Sub

import Task

type alias Model = String
type alias Msg = String

main : Program Never
main =
    Html.App.program
        { init = ("Hello, world!", change "It changed!")
        , view = Html.text
        , update = update
        , subscriptions = always Sub.none
        }

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    (msg, Cmd.none)

change : Msg -> Cmd Msg
change msg =
    Task.perform identity identity (Task.succeed msg)
```

Now, in the `init` of our application, we create an initial `Cmd` for our `Msg` so TEA can properly route it to our `update` function, which changes the `Model`. And, when we run the app, we can see that it works.

### More Complex Messages

One part glossed over above were the transform functions `onError` and `onSuccess`. For the example, they were both just set to `identity`. This was possible, because the task was generating a `String`, which also happens to be the same data type as our `Msg`. But, usually that won't be the case. Let's modify our `Msg` data type so that instead of a `String`, let's make it a `Maybe`.

```elm
type alias Msg = Maybe String
```

Now, our `update` function needs to understand that *maybe* (ha!) the `Msg` doesn't have anything for us...

```elm
update msg model =
    case msg of
        Just newModel -> (newModel, Cmd.none)
        Nothing -> (model, Cmd.none)
```

Last, our `changeModel` function needs to take a `String` and transform the result of the `Task` into a `Msg`.

```elm
change : String -> Cmd Msg
change s =
    Task.perform (always Nothing) Just (Task.succeed s)
```

Excellent! If we run, we should see everything still works.

Just for kicks, let's make sure it does the right thing if the task fails. We'll do this by creating a `Task` that we know will fail.

```elm
    Task.perform (always Nothing) Just (Task.fail 0)
```

And, just as it should, the `model` doesn't change.

### Quick Summary

Let's recap what we've discovered...

* We initial our program with an initial `Model` and `Cmd`
* A `Cmd` is a type wrapper so TEA can (safely) route our own `Msg` values to `update`
* A `Cmd` is created by performing a `Task`
* A `Task` can fail or succeed
* The program must transform the result of a `Task` into a `Msg`

### Subscriptions

Besides `Cmd`, another way of getting TEA to send a `Msg` to our `update` function is with a subscription (`Sub`) to an event. There are many different events that can be subscribed to (mouse, keyboard, time, and more). And these are all done via the `subscriptions` function of your program.

Every time your `model` is updated, TEA calls the `subscriptions` function to ask the application for a list of subscriptions it should listen to, given the current `model`.

As an example, let's create a simple subscription that updates our `Model` with the current time about every second.

```elm
subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every Time.second (Just << toString)
```

What is happening?

* When our `model` changes, the `subscriptions` function is called
* It should return a `Sub` that it will listen to
* In this case, the subscription is `Time.every Time.second`
* Just like a `Task`, we supply a function to transform the subscription data (`Time`) into a `Msg`
* The resulting `Msg` will be routed via TEA to `update`

*Note: if you have many events you'd like to subscribe to, use [`Sub.batch`](http://package.elm-lang.org/packages/elm-lang/core/4.0.0/Platform-Sub#batch) to aggregate multiple subscriptions into a single subscription.*

### Summarizing The Elm Architecture

* TEA is *the* method of building applications in Elm
* It wraps your program in the `Model`, `View`, `Update` pattern
* You initialize the program with the `Model`
* You provide the program with a function to render the `Model` (the `View`)
* You define a message type that is used to `Update` the `Model`
* The messages are wrapped - for type safety - into `Cmd` and `Sub`
* A `Cmd` is the result of a `Task`
* A `Sub` is the result of an event subscription
* You transform the results of task and subscriptions into your message type
* The `Cmd` and `Sub` are used by TEA to route your message to the `Update`

That's it!

It's very important that you understand this moving forward. Once it "clicks", Elm is wonderful to use.

## Putting it All Together

Next is a walk-through of using TEA to create a very simple Hacker News reader. It won't have all the features of the reader in this repo, but it will get you started and you should be able to use the source code in this repository to take your version to the next level.

Coming soon... 