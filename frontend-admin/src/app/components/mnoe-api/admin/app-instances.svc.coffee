# Service for managing the app instances
@App.service 'MnoeAppInstances', (MnoeAdminApiSvc) ->
  _self = @

  # Store selected organization app instances
  @appInstances = []

  @terminate = (id) ->
    MnoeAdminApiSvc.one('app_instances', id).remove().then(
      (response) ->
        # Remove the corresponding app from the list
        _.remove(_self.appInstances, {id: id})
    )


  return @
