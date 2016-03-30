@App.factory 'MnoeApiSvc', ($log, Restangular, inflector) ->
  return Restangular.withConfig((RestangularProvider) ->
    RestangularProvider.setBaseUrl('/mnoe/jpi/v1/admin')
    RestangularProvider.setDefaultHeaders({Accept: "application/json"})
    RestangularProvider.setFullResponse(true)

    # Unwrap api response
    RestangularProvider.addResponseInterceptor(
      (data, operation, what, url, response, deferred) ->
        extractedData = null
        if (operation == 'getList')
          extractedData = data[what]
        else if (operation == 'get' || operation == 'put' || operation == 'post')
          what = inflector.singularize(what)
          extractedData = data[what]
        else
          extractedData = data
        return extractedData
    )
  )
