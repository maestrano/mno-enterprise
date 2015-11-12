# Service for managing the users.
@App.service 'MnoeUsers', (MnoeApiSvc) ->
  _self = @

  @list = () ->
    MnoeApiSvc.all('users').getList()

  @get = (id) ->
    MnoeApiSvc.one('users', id)

  return @
