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

Save the above file as `Main.elm`, and build it with `elm make Main.elm`. It should successfully compile a `index.html` file that you can open in your browser.

Let's improve the edit-compile-test loop, though, with Elm Reactor, which will auto-compile for us after we make changes and refresh the page.

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

Internally, a `Cmd` is an operation that the Elm runtime will perform. Presumably this operation is native JavaScript, but it could also be an asynchronous operation and/or something that could fail. It then returns the result of that operation back to our application. 

However, the only way for our application to receive this value is via our `update` function. But, this poses a problem since our `update` function is defined as

```elm
update : msg -> Model -> (Model, Cmd msg)
```

Notice the first input to `update` is of type `msg`? This could be anything we want, but the type has to remain consistent throughout the entire program. We can't have the Elm runtime call `update` with a `Time` value from one operation, but then an `Http` result from another.

Now, the astute reader will notice that the `Cmd` type wraps our `msg` type. This enables us - when we perform an operation - to provide a function that converts the return value of that operation into a `msg`. That way, at a later point, when the operation is executed, the runtime can transform it into a `msg`, and then eventually pass that `msg` to our `update` function.

Let's put this into practice by defining our `Msg` type to just be a `String`. Whenever our application receives a `Msg`, it updates the current model to the value of the `Msg`.

```elm
type alias Model = String
type alias Msg = String
```

Next, let's change the definition of our `update` function to properly accept our new `Msg` type, and update the model appropriately.

```elm
update : Msg -> Model -> (Model, Cmd Msg)
update new model =
    (new, Cmd.none)
```

Okay, now we just need to tell the Elm runtime to perform an operation that will eventually result in our `update` being called with a `Msg`. There are many ways of doing this, but for this tutorial we'll [perform](http://package.elm-lang.org/packages/elm-lang/core/4.0.0/Task#perform) a [Task](http://package.elm-lang.org/packages/elm-lang/core/4.0.0/Task).

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
        { init = ("Hello, world!", changeModel "It changed!")
        , view = Html.text
        , update = update
        , subscriptions = always Sub.none
        }

update : Msg -> Model -> (Model, Cmd Msg)
update new model =
    (new, Cmd.none)

changeModel : String -> Cmd Msg
changeModel string =
    let
        onError = identity
        onSuccess = identity
    in
    Task.perform onError onSuccess (Task.succeed string)
```

Now, in the `init` of our application, we create an initial `Cmd` operation, which the Elm runtime will execute in the background. We did this by calling `Task.perform`. And the task we created to be performed is `Task.succeed string`.

Along with the task, we tell Elm how to transform failure and success return values into a `Msg`. Since we know `Task.succeed` can't fail, and the result of the operation is a `Msg` already, we can use the `identity` function.

Now, if we run the program, we'll see that it says "Hello, world!" ever so briefly, but then quickly changes to "It changed!".

### A More Complex Msg

Usually, your `Msg` type won't be so simple. Let's modify our `Msg` data type so that instead of a `String`, let's make it a `Maybe`.

```elm
type alias Msg = Maybe String
```

Now, our `update` function needs to understand that *maybe* (ha!) the `Msg` doesn't have anything for us...

```elm
update msg model =
    case msg of
        Just new -> (new, Cmd.none)
        Nothing -> (model, Cmd.none)
```

Last, let's fix our `changeModel` function so that it properly transforms the resulting task into our new `Msg` type based on whether or not the task succeeds or fails.

```elm
changeModel : String -> Cmd Msg
changeModel string =
    let
        onError = always Nothing
        onSuccess = Just
    in
    Task.perform onError onSuccess (Task.succeed string)
```

Excellent! If we run, we should see everything still works. And, just for kicks, let's make sure it does the right thing if the task fails. We'll do this by creating a `Task` that we know will fail.

```elm
    Task.perform onError onSuccess (Task.fail string)
```

And, just as it should, the `model` doesn't change.

### Quick Summary

Let's recap...

* We initialize our program with an initial `Model` and `Cmd`.
* A `Cmd` is an operation performed by the Elm runtime sometime later.
* For type safety, the result of an operation is transformed into a `Msg` type.
* The runtime then sends the resulting `Msg` to our `update` function.
* Most `Cmd` operations can succeed or fail.

So, when you see a return value from an Elm function that is a `Cmd`, you know that it is an operations that will be executed sometime later by the Elm runtime, and the result of which will eventually make it to your `update` function. 

### Subscriptions

Besides `Cmd`, another way of getting a `Msg` to our `update` function is via subscriptions (the `Sub` type). If you understand `Cmd`, though, subscriptions are a walk in the park.

The `Sub` type represents an event that the application listens to, and the Elm runtime will forward to the `update` function with the data associated with that event.

But, just like the results of operations, events contain data of all different types. So, when we subscribe to one, we also need to tell the Elm runtime how to transform the data of that event into our application's `Msg` type.

As an example, let's modify our program to create a simple subscription that updates our `Model` with the current time about every second.

```elm
main : Program Never
main =
    Html.App.program
        { init = ("Hello, world!", Cmd.none)
        , view = Html.text
        , update = update
        , subscriptions = subscriptions
        }
        
subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every Time.second (Just << toString)
```

When our application begins, and whenever the model changes, the `subscriptions` function is called. The event we're going to listen to is `Time.every Time.second`: an event that will fire once every second, and whose result is the current time. And the function we're using to transform the event's result into a `Msg` is `Just << toString`.

When our program starts, we'll start listening for the event, and when it trips, we'll transform the current time into our `Msg` type, which will then get routed along by the runtime into our `update` function.

That's it.

*Note: if you have many events you'd like to subscribe to, use [`Sub.batch`](http://package.elm-lang.org/packages/elm-lang/core/4.0.0/Platform-Sub#batch) to aggregate multiple subscriptions into a single subscription.*

### Summarizing The Elm Architecture

* TEA is *the* method of building applications in Elm.
* It wraps your program in the `Model`, `View`, `Update` pattern.
* You initialize the program with the `Model` and `Cmd`.
* You provide the program with a function to render the `Model` (the `View`).
* You define a message type that is used to `Update` the `Model`.
* A `Cmd` an operation that will be performed later by the Elm runtime.
* A `Sub` is a subscription to an event.
* You transform operation results and event data into your message type.
* The `Update` is called by the Elm runtime with your transformed message.

That's it!

It's very important that you understand this moving forward. And once it "clicks", Elm is wonderful to use.
