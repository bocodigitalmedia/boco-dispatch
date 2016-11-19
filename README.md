# boco-dispatch
Dispatcher (ala Flux)

## Installation

```sh
npm install boco-dispatch
```

## Usage

```coffee
BocoDispatch = require 'boco-dispatch'

dispatcher = new BocoDispatch.Dispatcher

cb1 = dispatcher.register (dispatch) ->
  if dispatch.message is 'hello'
    dispatch.waitFor cb3, cb2
    console.log 1, dispatch.payload.message

cb2 = dispatcher.register (dispatch) ->
  if dispatch.message is 'hello'  
    console.log 2, dispatch.payload.message

cb3 = dispatcher.register (dispatch) ->
  if dispatch.message is 'hello'
    console.log 3, dispatch.payload.message

cb4 = dispatcher.register (dispatch) ->
  if dispatch.message is 'goodbye'
    console.log 4, dispatch.payload.message

dispatcher.dispatch message: 'hello'
dispatcher.dispatch message: 'goodbye'

# =>
# 3 hello
# 2 hello
# 1 hello
# 4 goodbye
```
