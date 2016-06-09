@App.factory 'MnoeApiSvc', ($log, Restangular, inflector) ->
  return Restangular.withConfig((RestangularProvider) ->
    RestangularProvider.setBaseUrl('/mnoe/jpi/v1')
    RestangularProvider.setDefaultHeaders({Accept: "application/json"})
    RestangularProvider.setFullResponse(true)

    # Unwrap api response
    RestangularProvider.addResponseInterceptor(
      (data, operation, what, url, response, deferred) ->

        # If the what starts with a '/', return the data as it is
        # Used if the payload is not correctly formatted
        # (eg. MnoeApiSvc.oneUrl('/marketplace'))
        if (_.startsWith(what, '/'))
          return data

        extractedData = null
        # On getList extract and restangularize the objects list
        if (operation == 'getList')
          extractedData = data[what]
        # Extract and restangularize the object
        else if (operation == 'get' || operation == 'put' || operation == 'post')
          what = inflector.singularize(what)
          if (data[what])
            extractedData = data[what]
          else
            extractedData = data
        else
          extractedData = data
        return extractedData
    )
  )
