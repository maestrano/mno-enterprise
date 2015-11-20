# Service for managing the users.
@App.service 'MnoeOrganizations', (MnoeApiSvc) ->
  _self = @

  @list = () ->
    MnoeApiSvc.all('organizations').getList()

  @inArrears = () ->
    MnoeApiSvc.all('organizations').all('in_arrears').getList()

  @get = (id) ->
    MnoeApiSvc.one('organizations', id).get()

  return @
