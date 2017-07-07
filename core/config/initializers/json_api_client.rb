# MonkeyPatching json_api_client, see: https://github.com/chingor13/json_api_client/pull/263
JsonApiClient::Resource.include JsonApiClientExtension::ResourceExtension
