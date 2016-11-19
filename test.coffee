BocoDispatch = require './source'
assert = require 'assert'

dispatcher = new BocoDispatch.Dispatcher

results = []

cb1 = dispatcher.register (d) ->
  d.waitFor cb2, cb3 if d.payload is 1
  results.push "cb1:#{d.payload}"

cb2 = dispatcher.register (d) ->
  d.waitFor cb1, cb3 if d.payload is 2
  results.push "cb2:#{d.payload}"

cb3 = dispatcher.register (d) ->
  d.waitFor cb1, cb2 if d.payload is 3
  results.push "cb3:#{d.payload}"


dispatcher.dispatch 1
dispatcher.dispatch 2
dispatcher.dispatch 3

expected =
  """
  cb2:1
  cb3:1
  cb1:1
  cb1:2
  cb3:2
  cb2:2
  cb1:3
  cb2:3
  cb3:3
  """

assert.equal expected, results.join("\n")
