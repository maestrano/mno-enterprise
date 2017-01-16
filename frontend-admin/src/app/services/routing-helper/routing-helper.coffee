@App.service 'RoutingHelper', ($state, $q) ->
  _self = @

  # Used to redirect to home if condition is not met
  @skipUnlessCondition = (condition) ->
    if condition
      return $q.resolve()
    else
      $timeout(->
        # Runs after the main promise has been rejected.
        $state.go('dashboard.home')
      )
      $q.reject()

  return @
