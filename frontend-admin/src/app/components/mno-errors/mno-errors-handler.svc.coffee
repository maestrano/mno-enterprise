# Service to manage errors from RoR API on forms
@App.service 'MnoErrorsHandler', ($log) ->
  _self = @

  errorCache = null

  @processServerError = (serverError, form) ->
    $log.error('An error occurred:', serverError)
    return if _.startsWith(serverError.data, '<!DOCTYPE html>')
    if 400 <= serverError.status <= 499 # Error in the request
      # Save the errors object in the scope
      errorCache = serverError
      # Set each error fields as not valid
      _.each errorCache.data, (errors, key) ->
        _.each errors, ->
          if form[key]?
            form[key].$setValidity 'server', false
          else
            $log.error('MnoErrorsHandler: cannot find field:' + key)

  @errorMessage = (name) ->
    result = []
    if errorCache?
      _.each errorCache.data[name], (msg) ->
        result.push msg
    result.join ', '

  @resetErrors = (form) ->
    if errorCache?
      _.each errorCache.data, (errors, key) ->
        _.each errors, ->
          if form[key]?
            form[key].$setValidity 'server', null
      errorCache = null

  @onlyServerError = (form) ->
    # Check if there is errors that are not server type
    (_.every form.$error, (v, k) -> k == 'server')

  return @
