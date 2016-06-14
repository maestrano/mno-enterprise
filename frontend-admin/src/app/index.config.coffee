@App
  .config(($logProvider, toastrConfig) ->
    # Enable log
    $logProvider.debugEnabled true
    # Set options third-party lib
    toastrConfig.allowHtml = true
    toastrConfig.timeOut = 3000
    toastrConfig.positionClass = 'toast-top-right'
    toastrConfig.preventDuplicates = true
    toastrConfig.progressBar = true
  )
  .config(($httpProvider) ->
    $httpProvider.interceptors.push(($q, $window, $injector, $log) ->
      return {
        responseError: (rejection) ->

          if rejection.status == 401
            # Inject the toastr service (avoid circular dependency)
            toastr = $injector.get('toastr')

            # Redirect the user to the dashboard or login screen
            $window.location.href = "/"

            # Display an error
            toastr.error("You are no longer connected or not an administrator, you will be redirected to the dashboard.")
            $log.error("User is not connected!")

          $q.reject rejection
      }
    )
  )
