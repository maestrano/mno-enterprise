@App.factory 'MnoeAdminApiSvc', (MnoeApiSvc) ->
  return MnoeApiSvc.all('admin')
