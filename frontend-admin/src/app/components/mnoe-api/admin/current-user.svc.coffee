# Service to update the current user

# We're not using angular-devise as the update functionality hasn't been
# merged yet.
# As we're using Devise + Her, we have custom routes to update the current user
# It then makes more sense to have an extra service rather than have customised
# fork of the upstream library


@App.service 'MnoeCurrentUser', ($window, $state, $q, $timeout, MnoeApiSvc) ->
  _self = @

  # Store the current_user promise
  # Only one call will be executed even if there is multiple callers at the same time
  userPromise = null

  # Save the current user in variable to be able to reference it directly
  @user = {}

  # Get the current user profile
  @getCurrentUser = ->
    return userPromise if userPromise?
    userPromise = MnoeApiSvc.one('current_user').get().then(
      (response) ->
        user = {
          name: response.data.name
          surname: response.data.surname
          adminRole: response.data.admin_role
          email: response.data.email
        }
        angular.copy(user, _self.user)
        response
    )

  @skipIfNotAdmin = () ->
    if _self.user.admin_role? && _self.user.admin_role == 'admin'
      return $q.resolve()
    else
      $timeout(->
        # Runs after the authentication promise has been rejected.
        $state.go('dashboard.home')
      )
      $q.reject()

  return @
