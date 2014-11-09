module Examples.Demo where
import Playground(..)
import Playground.Input(..)
import Keyboard.Keys as Key
import Keyboard.Keys (equals)

-- Define what you want the state of your program to be
type State = {x : Float, y : Float, c : Color}
initialState : State
initialState = {x = 0, y = 0, c = blue}

-- Define how the state of your program should be rendered
render : RealWorld -> State -> [Form]
render rw state = 
    let shape = circle 50 |> filled state.c |> move (state.x, state.y) 
    in [shape]

-- Define how your program is updated
update : RealWorld -> Input -> State -> State
update rw input state = 
    case input of
      Tap k ->
          if | k `equals` Key.one -> {state | c <- blue}
             | k `equals` Key.two -> {state | c <- red}
             | k `equals` Key.three -> {state | c <- green}
             | otherwise -> state
      Key k ->
          if | k `equals` Key.arrowLeft -> {state | x <- state.x - 5}
             | k `equals` Key.arrowRight -> {state | x <- state.x + 5}
             | k `equals` Key.arrowDown ->  {state | y <- state.y - 5}
             | k `equals` Key.arrowUp -> {state | y <- state.y + 5}
             | otherwise -> state
      otherwise -> state

playground : Playground State
playground = {render = render, update = update, initialState = initialState}

main : Signal Element
main = play playground