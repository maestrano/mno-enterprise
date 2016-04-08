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
    $httpProvider.interceptors.push(($q, $window, $injector) ->
      return {
        responseError: (rejection) ->
          if rejection.status == 401
            # Inject the toastr service (avoid circular dependency)
            toastr = $injector.get('toastr')

            # Display an error
            toastr.error("User is not connected!")
            console.log "User is not connected!"

          $q.reject rejection
      }
    )
  )
