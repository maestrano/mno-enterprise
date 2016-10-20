module Mno
  class BaseResource < ::JsonApiClient::Resource
    self.site = URI.join(MnoEnterprise.api_host, MnoEnterprise.mno_api_v2_root_path).to_s
    property :created_at, type: :time
    property :updated_at, type: :time
  end
end

Mno::BaseResource.connection do |connection|
  connection.use Faraday::Request::BasicAuthentication, MnoEnterprise.tenant_id, MnoEnterprise.tenant_key #

  # log responses
  connection.use Faraday::Response::Logger
end
