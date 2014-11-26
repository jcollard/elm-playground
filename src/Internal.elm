module Internal (..) where

import Graphics.Collage (collage, Form)
import Graphics.Element (Element)
import Signal (Signal, (<~), (~), mergeMany, sampleOn, constant, dropRepeats, keepWhen)
import Playground.Input(..)
import Dict(Dict)
import Dict
import Char
import Keyboard
import Keyboard.Keys as K
import Mouse
import Window
import Time (Time)
import Time
import Set
import Debug
import List
import List ((::))

draw : Bool -> (Int, Int) -> List Form -> Element
draw traceForms (w, h) fs =
    let forms = if traceForms then List.map (Debug.trace "forms") fs else fs
    in collage w h forms

debugToRealWorld : (Int, Int) -> (Int, Int) -> RealWorld
debugToRealWorld dim pos = Debug.watch "Real World" <| toRealWorld dim pos

toRealWorld : (Int, Int) -> (Int, Int) -> RealWorld
toRealWorld (width, height) (x, y) =
    let top = (toFloat height)/2
        bottom = -top
        right = (toFloat width)/2
        left = -right
        mouseX = (toFloat x) + left
        mouseY = top - (toFloat y)
    in { top = top,
         right = right,
         bottom = bottom,
         left = left,
         mouse = {x = mouseX, y = mouseY} }

realworld : Bool -> Signal RealWorld
realworld debug = 
    let trw = if debug then debugToRealWorld else toRealWorld
    in trw <~ Window.dimensions ~ Mouse.position

updater : Bool -> Bool -> (RealWorld -> Input -> state -> state) -> (RealWorld, List Input) -> state -> state
updater watchInputs watchState update (rw, is) state = 
    let is' = if watchInputs then Debug.watch "Inputs" is else is
        state' = if watchState then Debug.watch "State" state else state
    in List.foldl (update rw) state' is'

inputs : Time -> Signal (List Input)
inputs rate = mergeMany [click, lastPressed, withRate rate]

singleton : a -> List a
singleton x = [x]

-- Define Mouse Inputs
click : Signal (List Input)
click = singleton <~ sampleOn Mouse.clicks (constant MouseUp)

toInputs : Time -> Maybe Input -> List Input -> List Input
toInputs t click keys = 
    case click of
      Nothing -> (Passive t)::keys
      Just c -> (Passive t)::c::keys

withRate : Time -> Signal (List Input)
withRate rate = 
    let rate' = Time.fps rate in
    sampleOn rate' (toInputs <~ rate' ~ (dropRepeats (getMouseDown <~ Mouse.isDown)) ~ (dropRepeats keysDown))

getMouseDown : Bool -> Maybe Input
getMouseDown x = if x then Just MouseDown else Nothing

-- Define Keyboard Inputs
lastPressed : Signal (List Input)
lastPressed = 
    let match = (\c d -> Set.member c (Set.fromList d))        
        matchSig = match <~ Keyboard.lastPressed ~ mergeMany [Keyboard.keysDown, sampleOn (Time.delay 1 Keyboard.keysDown) (constant [])]
    in (\c -> List.map Tap << toKeys <| [c]) <~ (keepWhen matchSig 0 Keyboard.lastPressed)

keysDown : Signal (List Input)
keysDown = List.map Key << toKeys <~ Keyboard.keysDown

keys : Dict Char.KeyCode K.Key
keys = List.foldr Dict.union Dict.empty [alphaKeys, specialKeys, arrowKeys, numbers]

numbers : Dict Char.KeyCode K.Key
numbers = Dict.fromList <| List.map2 (,) numbers' numbers''

numbers' : List Char.KeyCode
numbers' = List.map Char.toCode ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']

numbers'' : List K.Key
numbers'' = [K.zero, K.one, K.two, K.three, K.four, K.five, K.six, K.seven, K.eight, K.nine]

arrowKeys : Dict Char.KeyCode K.Key
arrowKeys = Dict.fromList [(37, K.arrowLeft), (38, K.arrowUp), (39, K.arrowRight), (40, K.arrowDown)]

alphaKeys : Dict Char.KeyCode K.Key
alphaKeys = Dict.fromList <| List.map2 (,) alphas' alphas''

alphas' : List Char.KeyCode
alphas' = List.map Char.toCode ['a','b','c','d','e','f','g','h','i','j','k','l','m',
                           'n','o','p','q','r','s','t','u','v','w','x','y','z']

alphas'' : List K.Key
alphas'' = [K.a, K.b, K.c, K.d, K.e, K.f, K.g, K.h, K.i, K.j, K.k, K.l, K.m,
            K.n, K.o, K.p, K.q, K.r, K.s, K.t, K.u, K.v, K.w, K.x, K.y, K.z]

specialKeys : Dict Char.KeyCode K.Key
specialKeys = Dict.fromList [(17, K.ctrl), (16, K.shift), (32, K.space), (13, K.enter)]

toKeys : List Char.KeyCode -> List K.Key
toKeys = justs << List.map toKey

toKey : Char.KeyCode -> Maybe K.Key
toKey code = Dict.get code keys

justs : List (Maybe a) -> List a
justs chars = let helper = (\ xs acc -> 
                                case xs of
                                  [] -> acc
                                  (y::ys) -> case y of
                                               Just x -> helper ys (x::acc)
                                               Nothing -> helper ys acc)
              in helper chars []

