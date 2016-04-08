# Service for managing the users.
@App.service 'MnoeOrganizations', (MnoeApiSvc) ->
  _self = @

  @list = (limit, offset, sort) ->
    promise = MnoeApiSvc.all("organizations").getList({order_by: sort, limit: limit, offset: offset}).then(
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
    MnoeApiSvc.all("organizations").getList({terms: terms})

  @inArrears = () ->
    MnoeApiSvc.all('organizations').all('in_arrears').getList()

  @get = (id) ->
    MnoeApiSvc.one('organizations', id).get()

  @count = () ->
    MnoeApiSvc.all('organizations').customGET('count')

  return @
