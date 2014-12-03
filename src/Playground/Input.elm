module Playground.Input where

{-|
This module explains each type of Input that can be used in a Playground's
update function.

@docs RealWorld, Input

-}


import Keyboard.Keys as Keys
import Time (Time)

{-|
The RealWorld record contains information about the environment of the running
program.

* The `top`, `right`, `bottom`, and `left` fields represent the bounding box
  that will be rendered.

* The `mouse` field is a record containing the most recent x and y positions
  of the mouse within the rendered bounding box.
 -}
type alias RealWorld = { top : Float
                       , right : Float
                       , bottom : Float
                       , left : Float
                       , mouse : { x : Float, y : Float } 
                       }


{-|
Inputs are passed to a Playground's update function. If multiple inputs are
generated, the update function is called multiple times accumulating all of
the changes. Your update function will always be passed a Passive input and
it is guaranteed that the Passive input will occur before all other inputs.

* Tap k - Fires once when `k` is pressed

* Key k - Fires every time the update function is called while `k` is pressed

* MouseUp - Fires once when the left mouse button is released

* MouseDown - Fires every time the update function is called while the mouse is down

* Passive t - This input is always passed to the update function and expresses
  how many milliseconds have passed since the last update was accumulated.

 -}
type Input = Tap Keys.Key
           | Key Keys.Key
           | MouseUp
           | MouseDown
           | Passive Time
