# Service for managing the users.
@App.service 'MnoeUsers', ($q, MnoeAdminApiSvc) ->
  _self = @

  @list = (limit, offset, sort) ->
    promise = MnoeAdminApiSvc.all('users').getList({order_by: sort, limit: limit, offset: offset}).then(
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
    MnoeAdminApiSvc.all('users').getList({terms: terms})

  @get = (id) ->
    MnoeAdminApiSvc.one('users', id).get()

  @count = () ->
    MnoeAdminApiSvc.all('users').customGET('count')

  # Create a user if not already existing, and add it to an organization
  # POST /mnoe/jpi/v1/admin/organizations/:orgId/users
  @addUser = (organization, user) ->
    MnoeAdminApiSvc.one('organizations', organization.id).all('/users').post({user: user})

  # Invite a user to join an organization
  # POST /mnoe/jpi/v1/admin/organizations/:orgId/users/:userId/invite
  @inviteUser = (organization, user) ->
    MnoeAdminApiSvc.one('organizations', organization.id).one('users', user.id).doPOST({}, 'invite')

  # Send an email to a user with the link to the registration page
  # POST /mnoe/jpi/v1/admin/users/send_signup_email
  @sendSignupEmail = (email) ->
    MnoeAdminApiSvc.all('/users').doPOST({user: {email: email}}, 'send_signup_email')

  return @
