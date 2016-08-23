# Service to manage app instances statuses and paths
@App.service 'MnoAppsInstances', () ->
  _self = @

  # Is the app instance connected?
  @isConnected = (instance) ->
    instance.stack == 'cube' || instance.stack == 'cloud' || _self.isOauthConnected(instance)

  # Is the app instance connected with oauth?
  @isOauthConnected = (instance) ->
    instance.stack == 'connector' && instance.oauth_keys_valid

  # Path to connect this app instance and redirect to the current page
  @oAuthConnectPath = (instance) ->
    redirect = window.encodeURIComponent("#{location.pathname}#{location.hash}")
    "/mnoe/webhook/oauth/#{instance.uid}/authorize?redirect_path=#{redirect}"

  # Can the app instance be data synced
  @canBeDataSynced = (instance) ->
    instance.stack == 'connector' && instance.oauth_keys_valid

  # Path to sync this app instance
  @dataSyncPath = (instance) ->
    "/mnoe/webhook/oauth/#{instance.uid}/sync"

  # Can this app instance be disconnected
  @canBeDisconnected = (instance) ->
    instance.stack == 'connector' && instance.oauth_keys_valid

  # Path to disconnect this app instance
  @disconnectPath = (instance) ->
    "/mnoe/webhook/oauth/#{instance.uid}/disconnect"

  return @
