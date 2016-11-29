# Service for managing the comments and ratings.
@App.service 'MnoeRatings', (MnoeAdminApiSvc) ->
  _self = @

  # GET List /mnoe/jpi/v1/admin/app_user_ratings
  @list = () ->
    MnoeAdminApiSvc.all('app_user_ratings').getList().then(
      (response) ->
        response
      (error) ->
        # Display an error
        $log.error('Error while fetching ratings', error)
        toastr.error('An error occured while fetching the ratings.')
    )
 
  # UPDATE /mnoe/jpi/v1/admin/app_user_ratings/1
  @updateRating = (rating) ->
    promise = MnoeAdminApiSvc.one('app_user_ratings', rating.id).patch({status: rating.status}).then(
      (response) ->
        response
      (error) ->
        # Display an error
        $log.error('Error while updating rating', error)
        toastr.error('An error occured while updating the rating.')
    )

  # future implementation waiting for backend to be ready
  # @removeRating = (id) ->
  #   promise = MnoeAdminApiSvc.one('app_user_rating', id).then(
  #     (response) ->
  #       response
  #     (error) ->
  #       # Display an error
  #       $log.error('Error while deleting rating', error)
  #       toastr.error('An error occured while deleting the rating.')
  #   )

  return @
