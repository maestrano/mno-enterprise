require 'her'

# Configure HER for Maestrano Enterprise Endpoints
MNO_ENTERPRISE_API_V1 = Her::API.new
MNO_ENTERPRISE_API_V1.setup url: "#{URI.join(MnoEnterprise.mno_api_host,MnoEnterprise.mno_api_root_path).to_s}" do |c|
  # Request
  c.use Faraday::Request::BasicAuthentication, MnoEnterprise.tenant_id, MnoEnterprise.tenant_key
  c.use Faraday::Request::UrlEncoded
  
  # Response
  c.use Her::Middleware::DefaultParseJSON

  # Adapter
  c.use Faraday::Adapter::NetHttp
end