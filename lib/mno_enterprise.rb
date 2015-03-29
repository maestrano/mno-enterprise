require 'haml'
require 'jbuilder'
require 'cancancan'
require 'devise'
require 'devise/strategies/remote_authenticatable'
require "her"
require "her_extension/her_orm_adapter"
require "her_extension/model/relation"
require "her_extension/model/attributes"
require "her_extension/model/parse"
require "her_extension/model/associations/association"
require "her_extension/model/associations/association_proxy"
require "her_extension/model/associations/has_many_association"
require "her_extension/middleware/mnoe_api_v1_parse_json"
require "mno_enterprise/engine"


module MnoEnterprise
  
  # The Maestrano Enterprise API Host
  mattr_accessor :mno_api_host
  @@mno_api_host = "https://api-enterprise.maestrano.com"
  
  # The Maestrano Enterprise API base path
  mattr_accessor :mno_api_root_path
  @@mno_api_root_path = "/v1"
  
  # Maestrano Enterprise Tenant ID
  mattr_accessor :tenant_id
  @@tenant_id = nil
  
  # Maestrano Enteprise Tenant Key
  mattr_accessor :tenant_key
  @@tenant_key = nil
  
  mattr_reader :mnoe_api_v1
  @@mnoe_api_v1 = nil
  
  # Default way to setup MnoEnterprise. Run rails generate mno-enterprise:install to create
  # a fresh initializer with all configuration values.
  def self.configure
    yield self
    self.configure_api
  end
  
  private
    # Return the options to use in the setup of the API
    def self.api_options
      { url: "#{URI.join(@@mno_api_host,@@mno_api_root_path).to_s}", send_only_modified_attributes: true }
    end
    
    # Configure the Her for Maestrano Enteprise API V1
    def self.configure_api
      # Configure HER for Maestrano Enterprise Endpoints
      @@mnoe_api_v1 = Her::API.new
      @@mnoe_api_v1.setup self.api_options  do |c|
        # Request
        c.use Faraday::Request::BasicAuthentication, @@tenant_id, @@tenant_key
        c.use Faraday::Request::UrlEncoded
  
        # Response
        #SecondLevelParseJSON
        c.use Her::Middleware::MnoeApiV1ParseJson

        # Adapter
        c.use Faraday::Adapter::NetHttp
      end
    end
end
