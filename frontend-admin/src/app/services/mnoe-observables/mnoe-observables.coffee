@App.service 'MnoeObservables', () ->
  _self = @

  observersCallbacks = {}

  # Subscribe callback functions to be called if observable has been changed
  @registerCb = (name, cb) ->
    observersCallbacks[name] = [] if _.isEmpty(observersCallbacks[name])
    observersCallbacks[name].push(cb)

  # Call this when the observable has been changed
  @notifyObservers = (name, object) ->
    _.forEach observersCallbacks[name], (callback) ->
      callback(object)

  @unsubscribe = (name, cb) ->
    _.remove(observersCallbacks[name], cb) ->
      delete observersCallbacks[name] if _.isEmpty(observersCallbacks[name])

  return
