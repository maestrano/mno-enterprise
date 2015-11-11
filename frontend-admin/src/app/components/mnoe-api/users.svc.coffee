# Service for managing the users.
@App.service 'MnoeUsers', ($log, $q, Restangular, MnoeApiSvc) ->
  _self = @

  usersApi = MnoeApiCacheSvc.all("users")

  @users = []

  @list = () ->
    return usersApi.getList().then(
      (response) ->
        _self.users = response
        return response
    )

  @save = (user, index) ->
    user.save()

  @delete = (reminder) ->
    reminder.remove()

  return @
