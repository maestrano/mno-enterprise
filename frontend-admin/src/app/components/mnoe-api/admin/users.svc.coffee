# Service for managing the users.
@App.service 'MnoeUsers', ($q, $log, MnoeAdminApiSvc, MnoeObservables, OBS_KEYS) ->
  _self = @

  @list = (limit, offset, sort) ->
    promise = MnoeAdminApiSvc.all('users').getList({order_by: sort, limit: limit, offset: offset}).then(
      (response) ->
        MnoeObservables.notifyObservers(OBS_KEYS.userChanged, promise)
        response
    )

  @staffs = (limit, offset, sort, params = {}) ->
    # Require only users with an admin role (gets any role, not necessarly defined in the frontend)
    if ! params['where[admin_role.in][]']
      params['where[admin_role.not]'] = ''

    return _getStaffs(limit, offset, sort, params)

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

  # Create a user if not already existing with an admin_role
  # POST /mnoe/jpi/v1/admin/users/
  @addStaff = (user) ->
    promise = MnoeAdminApiSvc.all('users').post({user: user}).then(
      (response) ->
        MnoeObservables.notifyObservers(OBS_KEYS.staffAdded, promise)
        response
    )

  @updateStaff = (user) ->
    promise = MnoeAdminApiSvc.one('users', user.id).patch({user: user}).then(
      (response) ->
        MnoeObservables.notifyObservers(OBS_KEYS.staffChanged, promise)
        response
    )

  # Update the admin-role of a staff to nothing
  # UPDATE /mnoe/jpi/v1/admin/users/:id
  @removeStaff = (id) ->
    promise = MnoeAdminApiSvc.one('users', id).patch({admin_role: ""}).then(
      (response) ->
        MnoeObservables.notifyObservers(OBS_KEYS.staffChanged, promise)
      (error) ->
        # Display an error
        $log.error('Error while deleting user', error)
        toastr.error('An error occured while deleting the user.')
    )

  # Invite a user to join an organization
  # POST /mnoe/jpi/v1/admin/organizations/:orgId/users/:userId/invite
  @inviteUser = (organization, user) ->
    MnoeAdminApiSvc.one('organizations', organization.id).one('users', user.id).doPOST({}, '/invites')

  # Send an email to a user with the link to the registration page
  # POST /mnoe/jpi/v1/admin/users/signup_email
  @sendSignupEmail = (email) ->
    MnoeAdminApiSvc.all('/users').doPOST({user: {email: email}}, 'signup_email')

  _getStaffs = (limit, offset, sort, params = {}) ->
    params["order_by"] = sort
    params["limit"] = limit
    params["offset"] = offset
    return MnoeAdminApiSvc.all("users").getList(params)

  return @
