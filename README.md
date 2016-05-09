# HN Trolling in Elm

This is a simple [Hacker News](http://news.ycombinator.com/) reader written in [Elm](http://elm-lang.org/). It was used as a simple "Learning Elm" app for myself, but others may learn from it as well. 

This README is here to explain the modules and the overall architecture as well as introduce Elm to newcomers with a progressive approach. If you see something wrong or have suggestions on how to improve the code or this README, please create an issue or email me. ;-)

## Quickstart

I'll assume you have [Elm](http://elm-lang.org/install/) installed, your [favorite editor](https://code.visualstudio.com/) configured, and a basic understanding of the Elm syntax (from Haskell or ML). If not, there are many other [great tutorials](https://pragmaticstudio.com/elm) out there.

This page is about learning (fundamentally) how to put together signals and tasks in Elm to do what you want. And how to do so without all the [helper libraries](http://package.elm-lang.org/packages/evancz/start-app/2.0.2/) that most of the examples out there use, and are great once you really understand what's going on under-the-hood, but simply obfuscate until then.

With that out of the way, once you've cloned this repository, you should be able to simply run the Elm Reactor and see the app running.

    $ elm reactor
    Listening on http://127.0.0.1:8000/

Now, open your browser to the URL above and click on `Main.elm` to open it to see the latest posts on Hacker News.

From here on, it would be best for you to create a new folder in which you will slowly develop your own version of this app. I like to start small, and grow into the final application.

Also, there are many areas where the code presented below could be significantly shortened using method exposing, function composition, piping, and currying. I've chosen (quite intentionally) to use the long-form of everything so the reader can see *explicitly* what's happening, with no shortcuts being taken. 

Taking that approach, without further adieu...

## Let's Start At The Very Beginning...

Step one is to get our version of "Hello, world" up. So, let's create our `Main.elm` file and get something up visible...

```elm
module Main where

import Json.Decode exposing ((:=))
import Html
import Html.Attributes
import Http
import Task

main : Html.Html
main = Html.body [] [Html.text "Hello, world!"] 
```

*Note: don't forget to install the HTML and HTTP packages... `elm package install evancz/elm-html` and `elm package install evancz/elm-http`*

## Downloading HN Items

Next, let's start by downloading all the Hacker News items and simply displaying them. We can do this with the [Hacker News API](https://github.com/HackerNews/API), specifically the `/topstories` route:

```elm
-- the topstories route
topStoriesUrl = "https://hacker-news.firebaseio.com/v0/topstories.json"

-- create a task to download the top stories on hacker news
topStories : Task.Task Http.Error String
topStories = Http.getString topStoriesUrl
```

This required creating a [Task](http://package.elm-lang.org/packages/elm-lang/core/3.0.0/Task). The task runs in the background, and - upon completion - will either produce an error or a string: the body of the response. But, it is only a Task *object*; it doesn't run simply by existing. Instead, a [port](http://elm-lang.org/guide/reactivity#tasks) is used to run a Task. So, let's create a port to run it.

```elm
-- run the task
port latest : Task.Task Http.Error String
port latest = topStories
```

*Note: there is a lot more to ports than just running tasks, but for now, we'll leave it as just a way to ask Elm to do something for us.*

Okay. We now have a simple skeleton: a main function that produces our HTML output, a task to download the top stories from Hacker News, and a port that runs the task.

So, how do we get the results of the task into our HTML?

Answer: [Signals](http://package.elm-lang.org/packages/elm-lang/core/3.0.0/Signal). 

## Signaling Values

The Elm definition of a Signal is "...a value that changes over time." And - as it turns out - our background Task is exactly that: a value that will either be an Http.Error or a String, but "later".

We need a method of getting the value that is returned from the Task to the `main` function so it can be rendered. This is done by creating a [Signal Mailbox](http://package.elm-lang.org/packages/elm-lang/core/3.0.0/Signal#Mailbox). 

A Mailbox has a Signal, as well as an Address, which is used to send value updates to the Signal. Other code can then listen for the Signal to change and execute code on it.

Let's start by creating a mailbox to write to.

```elm
-- a mailbox for all the latest hacker news items
items : Signal.Mailbox String
items = Signal.mailbox ""
```

Now, we need to send the response body gotten from the Task and send it to the mailbox. First, let's make a function that writes the response body to the mailbox...

```elm
-- update the items with the latest response
updateItems : String -> Task.Task a ()
updateItems body = Signal.send items.address body
```

Next, let's modify the `latest` port to call `updateItems` after having downloaded the top stories.

```elm
port latest : Task.Task Http.Error ()
port latest : topStories `Task.andThen` updateItems
```

*Note: if you aren't familiar with the `` `...` `` syntax in Elm, it's simply a way of using a 2-arity function as an infix operator. The above could also have been written `Task.andThen topStories updateItems`.* 

## Responding to Signals

Let's summarize where we are...

* We have a main function that returns HTML
* We created a Task that downloads top stories from Hacker News
* A mailbox is used to receive updates to a Signal
* A port runs the Task and then sends the response to the mailbox

All that should be left to do is wait for the Signal in the mailbox to change and then update the HTML accordingly. And this is done by using the [Signal.map](http://package.elm-lang.org/packages/elm-lang/core/3.0.0/Signal#map) function. Let's update `main` to do so...

```elm
main : Signal Html.Html
main = Signal.map (\body -> Html.body [] [Html.text body]) items.signal
```

Now, if you refresh `Main.elm` in your browser, you should have a blank page, which quickly updates to a JSON list of IDs, each of which corresponds to a Hacker News item.

All this in ~25 lines of code. Not too shabby. But we're far from done.

## Parsing JSON

Currently, we're just displaying the response body as a string. But, that body needs to be parsed into the list of IDs so each item can be downloaded in a task. So, instead of the `items` Mailbox being a String, let's make it a list of integer IDs.

```elm
items : Signal.Mailbox (List Int)
items = Signal.mailbox []
```

And, when we send the response body to the mailbox, we cannot send a string, we must update the items with a list of IDs.

```elm
updateItems : List Int -> Task.Task a ()
updateItems ids = Signal.send items.address ids
```

Of course, this means that the `topStories` cannot return a String either, but rather must parse the response body and decode it. Luckily for us, the `Http` module has a function to do this for us as long as we pass it a [Json decoder](http://package.elm-lang.org/packages/elm-lang/core/3.0.0/Json-Decode) to use.

```elm
topStories : Task.Task Http.Error (List Int)
topStories = Http.get (Json.Decode.list Json.Decode.int) topStoriesUrl
```

Finally, the Signal we're watching in `main` isn't producing a String any more, and therefor must be converted into one.

```elm
main : Signal Html.Html
main = Signal.map (\ids -> Html.body [] [Html.text (toString ids)]) items.signal
```

Now the body of the response is being parsed and the page should still display exactly the same way.

## Downloading Items

The next step is to actually download the individual Hacker News items from the list of IDs we've gotten. Let's quickly define a [record](http://elm-lang.org/docs/syntax#records) for each item to decode into.

```elm
-- a hacker news item
type alias Item =
    { id : Int
    , kind : String
    , title : String
    , url : Maybe String
    }
```

At this point we have to download the individual items from the list of IDs. To do this, we have two options available to us:

1. We can chain off the Task, creating a new Task for each ID or
2. Wait on the `item` Mailbox and create a new Signal with the final Items

Both of these are possible, but for this tutorial we'll go with option 1 (leaving option 2 as an exercise for the reader).

Now that we've decided on a course, the first step is to update the type signatures from `List Int` to `List Item` - the final value that should end up in the Mailbox.

```elm
-- update the items with the latest response
updateItems : (List Item) -> Task.Task a ()
updateItems xs = Signal.send items.address xs
```

There should now be a compile error on the `latest` port. This is because it's attempting to call `updateItems` with a list of IDs instead of a list of Items. To fix this, we need to chain Tasks together. So, let's create a set of functions that - given a list of IDs - will create a list of Tasks, downloading the Items, and then sequence them into a single Task.

```elm
itemUrl = "https://hacker-news.firebaseio.com/v0/item/"

-- create a sequence of tasks that will download hacker news items
downloadItems : List Int -> Task.Task Http.Error (List Item)
downloadItems ids = Task.sequence (List.map item ids)

-- download a single item from Hacker News give its ID
item : Int -> Task.Task Http.Error Item
item id = Http.get itemDecoder (itemUrl ++ (toString id) ++ ".json")

-- JSON decoder for an Item
itemDecoder : Json.Decoder.Decoder Item
itemDecoder =
    Json.Decoder.object4 Item
        ("id" := Json.Decode.int
        ("type" := Json.Decode.string)
        ("title" := Json.Decode.string)
        (Json.maybe ("url" := Json.string))
```

*Note: even though `Item` is a `type alias`, it is also a function that takes 4 parameters: an id, type, title, and optional url. The `object4` decoder chains the decoding of a JSON object and then passes the results of the keys parsed to the `Item` function.*

Now we can update the `latest` port to chain the Tasks together...

```elm
port latest = topStories
    `Task.andThen` downloadItems
    `Task.andThen` updateItems
```

If you run `Main.elm` now, it will probably take a while. This is because `topStories` returns a list of ~500 IDs. It's highly doubtful that you'd want all of them. So, let's trim that to only the top 20 for now.

```elm
downloadItems ids = Task.sequence (List.map item (List.take 20 ids))
```

## Filtering Stories

All sorts of things are posted to Hacker News: stories, polls, jobs, etc. For this tutorial, though, we're only going to care about the stories. So, let's create a new Signal that filters non-stories from the list of Items.

```elm
-- a signal that is only a list of story items 
stories : Signal (List Item)
stories = Signal.map (List.filter (\i -> i.kind == "story")) items.signal
```

As you can see, every time the `items` Mailbox is updated, `stories` will read and filter it into a new list of Items. We can now update `main` to watch the `stories` Signal instead.

```elm
main = Signal.map (\story -> Html.body [] [Html.text (toString story)]) stories
```

## A Better Presentation

Last, it would be nice to render the stories a bit nicer than they are currently...

```elm
-- create an ordered list of items
renderItems : List Item -> Html.Html
renderItems items = Html.ol [] (List.map render items)

-- create a list item
render : Item -> Html.Html
render item = Html.li [] [link item]

-- create a link to an item
link : Item -> Html.Html
link item =
    let def = "https://news.ycombinator.com/item?id=" ++ (toString item.id) in
    let url = Maybe.withDefault def item.url in
    Html.a [Html.Attributes.href url] [Html.text item.title]
```

And, let's update `main` to render them...

```elm
main = Signal.map (\items -> Html.body [] [renderItems items]) stories
```

That's it!

## What's Next?

Obviously the `elm-hn` reposity does considerably more...

* Ranks and sorts the stories
* Continuously updates the stories periodically
* Shows author, points, comments, ...
* Styles the output

All of these are pretty trivial once you have the full understanding of how to use Tasks, Signals, and ports. So, the above features are left as exercises to the reader. Look at the code and try and add them each yourself. And have fun doing it!
