# Service for managing the users.
@App.service 'MnoeOrganizations', (MnoeAdminApiSvc) ->
  _self = @

  @list = (limit, offset, sort) ->
    promise = MnoeAdminApiSvc.all("organizations").getList({order_by: sort, limit: limit, offset: offset}).then(
      (response) ->
        notifyListObservers(promise)
        response
    )

  observerCallbacks = []

  # Subscribe callback functions to be called if 'list' has been changed
  @registerListChangeCb = (callback) ->
    observerCallbacks.push(callback)

  # Call this when you know 'list' has been changed
  notifyListObservers = (listPromise) ->
    _.forEach observerCallbacks, (callback) ->
      callback(listPromise)

  @search = (terms) ->
    MnoeAdminApiSvc.all("organizations").getList({terms: terms})

  @inArrears = () ->
    MnoeAdminApiSvc.all('organizations').all('in_arrears').getList()

  @get = (id) ->
    MnoeAdminApiSvc.one('organizations', id).get()

  @count = () ->
    MnoeAdminApiSvc.all('organizations').customGET('count')

  @create = (organization) ->
    MnoeAdminApiSvc.all('/organizations').post(organization)

  return @
