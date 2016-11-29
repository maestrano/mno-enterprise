@App.directive('mnoeRatingsList', ($filter, $log, MnoeRatings) ->
  restric:'E'
  scope: {
  }
  templateUrl:'app/components/mnoe-ratings-list/mnoe-ratings-list.html'
  link: (scope) ->

    scope.editmode = []
    scope.listOfRatings = []
    scope.statuses = ['approved', 'rejected']

    fetchRatings = () ->
      return MnoeRatings.list().then(
        (response) ->
          scope.listOfRatings = response.data
      )

    scope.update = (rating) ->
      MnoeRatings.updateRating(rating).then(
        (response) ->
          # Remove the edit mode for this rating
          delete scope.editmode[rating.id]
      )

    # Future implementation
    # scope.remove = (rating) ->
    #   MnoeRatings.removeRating(rating.id).then( ->
    #     toastr.success("The #{rating.user_name}\'s rating has been successfully removed.")
    #   )

    fetchRatings()
    return
)
