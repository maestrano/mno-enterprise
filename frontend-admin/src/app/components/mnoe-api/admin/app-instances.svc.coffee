# Service for managing the app instances
@App.service 'MnoeAppInstances', (MnoeAdminApiSvc, toastr) ->
  _self = @

  # Delete the instance of an app
  @terminate = (id) ->
    MnoeAdminApiSvc.one('app_instances', id).remove().then(
      (response) ->
        # Apps has been succesfuly removed
      (error) ->
        # Something went wrong
        toastr.error("There was a problem and your app has not been deleted.")
    )


  return @
