configure = ({UUID} = {}) ->

  if typeof require is 'function'
    UUID ?= try require('uuid')

  CallbackStates =
    WAITING: 0
    PENDING: 1
    HANDLED: 2

  class Exception extends Error
    message: null
    payload: null
    name: null

    constructor: (payload) ->
      @payload = payload
      @message = @getMessage payload
      @name = @constructor.name
      Error.captureStackTrace @, @constructor

    getMessage: ->
      @constructor.name

  class HasCircularDependency extends Exception
    getMessage: ({id}) ->
      "Circular dependency detected while waiting for `#{id}`"

  class CannotDispatch extends Exception
    getMessage: ({dispatcher}) ->
      "Cannot dispatch, current dispatch not finished."

  class CallbackIdNotUnique extends Exception
    getMessage: ({id}) ->
      "Callback id is not unique: `#{id}`"

  class CallbackNotRegistered extends Exception
    getMessage: ({id}) ->
      "Callback not registered: `#{id}`"

  class Dispatch
    dispatcher: null
    payload: null
    callbackStates: null

    constructor: (props) ->
      @[key] = val for own key, val of props
      @callbackStates ?= {}

    getState: (id) ->
      @callbackStates[id] ? CallbackStates.WAITING

    setState: (id, state) ->
      @callbackStates[id] = state

    setPending: (id) ->
      @setState id, CallbackStates.PENDING

    setHandled: (id) ->
      @setState id, CallbackStates.HANDLED

    isPending: (id) ->
      @getState(id) is CallbackStates.PENDING

    isHandled: (id) ->
      @getState(id) is CallbackStates.HANDLED

    isWaiting: (id) ->
      @getState(id) is CallbackStates.WAITING

    send: ->
      @callbackStates = {}

      @dispatcher.getCallbackIds().forEach (id) =>
        @invokeCallback id if @isWaiting id

    invokeCallback: (id) ->
      @setPending id
      @dispatcher.getCallback(id)(@)
      @setHandled id

    waitFor: (ids...) ->
      ids.forEach (id) =>
        throw new HasCircularDependency {id} if @isPending id
        @invokeCallback(id) unless @isHandled id

  class Dispatcher
    callbacks: null
    currentDispatch: null

    constructor: (props) ->
      @[key] = val for own key, val of props
      @callbacks ?= {}
      @currentDispatch ?= null

    generateCallbackId: ->
      UUID()

    hasCallback: (id) ->
      @callbacks[id]?

    getCallback: (id) ->
      throw new CallbackNotRegistered {id} unless @hasCallback id
      @callbacks[id]

    getCallbackIds: ->
      (id for own id of @callbacks)

    setCallback: (id, callback) ->
      throw new CallbackIdNotUnique {id} if @hasCallback id
      @callbacks[id] = callback

    register: (callback, id) ->
      id ?= @generateCallbackId()
      @setCallback id, callback
      id

    unregister: (id) ->
      throw new CallbackNotRegistered {id} unless @hasCallback id
      delete @callbacks[id]

    isDispatching: ->
      @currentDispatch?

    dispatch: (payload) ->
      throw new CannotDispatch(dispatcher: @) if @isDispatching()

      @currentDispatch = new Dispatch {dispatcher: @, payload}
      @currentDispatch.send()
      delete @currentDispatch

  {
    configure
    CallbackStates
    Exception
    HasCircularDependency
    CannotDispatch
    CallbackIdNotUnique
    CallbackNotRegistered
    Dispatch
    Dispatcher
  }

module.exports = configure()
