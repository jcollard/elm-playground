module Playground where

{-|
The Playground Library is a layer that abstracts away the need to write explicit
Signals. To get started, one provides a `Playground` record and then passes that
record to `play`. 

## Quick Demo

The following is a quick Demo of a program that increments a number
repeatedly. When the space bar is pressed, the number is reset to 0.

```
import Playground(..)
import Playground.Input(..)
-- Increases an Int ~60 times per second. When the space bar is pressed, the Int
-- resets
update input state = 
  case input of
    Key Space -> 0
    otherwise -> state + 1

render (w, h) state = asText state

main = play { render = render, update = update, initialState = 0 }
```

## Playground Record

@docs Playground

## Playing a Playground

@docs play, Options, defaultOptions, playWithOptions

## Examples
* Increment
  - [Demo](http://people.cs.umass.edu/~jcollard/examples/Playground/build/Increment.html)
  - [Source](https://github.com/jcollard/Playground/blob/master/Examples/Increment.elm)
* Ball
  - [Demo](http://people.cs.umass.edu/~jcollard/examples/Playground/build/Demo.html)
  - [Source](https://github.com/jcollard/Playground/blob/master/Examples/Demo.elm)
* Mario
  - [Demo](http://people.cs.umass.edu/~jcollard/examples/Playground/build/Mario.html)
  - [Source](https://github.com/jcollard/Playground/blob/master/Examples/Mario.elm)


-}

import Internal(..)
import Playground.Input(..)
import Window

{-|
A Playground record defines the execution path for a program. To create one, you
must specify three fields: initialState, render, and update.

* The `initialState` field describes the state of the Playground after it has
  been loaded.

* The `render` field is a function which describes how your state should be
  transformed into a set of Forms that can be displayed.

* The `update` field is a function that takes in the RealWorld, an Input event,
  a State to update, and returns the updated State. All possible Inputs are 
  defined in Playground.Input. The RealWorld is defined in Playground.Input.
-}
type Playground state = { render : RealWorld -> state -> [Form],
                          initialState : state,
                          update : RealWorld -> Input -> state -> state }
                               

{-|
Plays a Playground with the `defaultOptions`.
-}
play : Playground state -> Signal Element
play = playWithOptions defaultOptions

{-|
Plays a Playground at the specified options.
-}
playWithOptions : Options -> Playground state -> Signal Element
playWithOptions options playground =
    let update = updater options.debugInput options.debugState playground.update
        ins = inputs options.rate
        rw = realworld options.debugRealWorld
        input = (,) <~ sampleOn ins rw ~ ins
    in draw options.traceForms 
           <~ Window.dimensions 
            ~ (playground.render <~ rw
                                  ~ foldp update playground.initialState input)

{-|
  Options that may be used when running a playground.

* `debugRealWorld` If true, enables a Watch on the RealWorld when debugging in `elm-reactor`.

* `debugState` If true, enables a Watch on the state of the program in `elm-reactor`.

* `debugInput` If true, enables a Watch on the Input to the program in `elm-reactor`.

* `traceForms` If true, traces all forms when run in `elm-reactor`.

* `rate` Specify the desired frames per second to attempt to run the playground with.
 -}
type Options = { debugRealWorld : Bool,
                 debugState : Bool,
                 debugInput : Bool,
                 traceForms : Bool,
                 rate : Time }

{-|
  The default options which can be used to easily specify which options you would like
  to use when running with `playWithOptions`. For example, if you want to run at
  30 frames per second and debug the state of the program, you could do the following:

```
main = 
  let options = { defaultOptions | debugState <- True
                                 , rate <- 30 }
  in playWithOptions { render = render, update = update, initialState = 0 }
```

 -}
defaultOptions = { debugRealWorld = False,
                   debugState = False,
                   debugInput = False,
                   traceForms = False,
                   rate = 60 }

