# Service for managing the users.
@App.service 'MnoeUsers', ($q, MnoeApiSvc) ->
  _self = @

  @list = (limit, offset, sort) ->
    promise = MnoeApiSvc.all("users").getList({order_by: sort, limit: limit, offset: offset}).then(
      (response) ->
        notifyListObservers(promise)
        response
    )

  observerCallbacks = []

  # Suscribe callback functions to be called if 'list' has been changed
  @registerListChangeCb = (callback) ->
    observerCallbacks.push(callback)

  # Call this when you know 'list' has been changed
  notifyListObservers = (listPromise) ->
    _.forEach observerCallbacks, (callback) ->
      callback(listPromise)

  @search = (terms) ->
    MnoeApiSvc.all("users").getList({terms: terms})

  @get = (id) ->
    MnoeApiSvc.one('users', id).get()

  @count = () ->
    MnoeApiSvc.all('users').customGET('count')

  return @
