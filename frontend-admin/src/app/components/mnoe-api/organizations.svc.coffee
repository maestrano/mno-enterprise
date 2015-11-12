# Service for managing the users.
@App.service 'MnoeOrganizations', (MnoeApiSvc) ->
  _self = @

  @list = () ->
    MnoeApiSvc.all('organizations').getList()

  @get = (id) ->
    MnoeApiSvc.one('organizations', id).get()

  return @
