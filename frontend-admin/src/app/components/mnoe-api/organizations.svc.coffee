# Service for managing the users.
@App.service 'MnoeOrganizations', (MnoeApiSvc) ->
  _self = @

  @list = () ->
    MnoeApiSvc.all('organizations').getList()

  @inArrears = () ->
    MnoeApiSvc.all('organizations').customGET('in_arrears')

  @get = (id) ->
    MnoeApiSvc.one('organizations', id).get()

  return @
