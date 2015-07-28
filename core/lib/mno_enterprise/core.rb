require 'prawn'
require 'prawn/table'
require 'money'
require 'deepstruct'
require 'jwt'
require 'countries'
require 'cancancan'
require 'devise'
require 'devise/strategies/remote_authenticatable'
require "her"
require "her_extension/her_orm_adapter"
require "her_extension/model/orm"
require "her_extension/model/relation"
require "her_extension/model/attributes"
require "her_extension/model/parse"
require "her_extension/model/associations/association"
require "her_extension/model/associations/association_proxy"
require "her_extension/model/associations/has_many_association"
require "her_extension/middleware/mnoe_api_v1_parse_json"
require "mno_enterprise/engine"

require 'mandrill'
require "mandrill_client"

require 'accountingjs_serializer'

module MnoEnterprise

  #==================================================================
  # MnoEnterprise Router
  # Centralizes all URLs available on the Maestrano Enterprise side
  #==================================================================
  class Router
    attr_accessor :terms_url

    def terms_url
      @terms_url || '#'
    end

    def launch_url(id,opts = {})
      host_url("/launch/#{id}",opts)
    end

    def authorize_oauth_url(id,opts = {})
      host_url("/oauth/#{id}/authorize",opts)
    end

    def disconnect_oauth_url(id,opts = {})
      host_url("/oauth/#{id}/disconnect",opts)
    end

    def sync_oauth_url(id,opts = {})
      host_url("/oauth/#{id}/sync",opts)
    end

    def impac_root_url
      URI.join(MnoEnterprise.impac_api_host,MnoEnterprise.impac_api_root_path)
    end

    private
      def base_path
        MnoEnterprise.mno_api_root_path
      end

      def host
        MnoEnterprise.mno_api_host
      end

      def host_url(path,opts = {})
        url = URI.join(host,"#{base_path}#{path}").to_s
        url += "?#{opts.to_query}" if opts.any?
        url
      end
  end

  #==================================================================
  # Module definition
  #==================================================================

  #====================================
  # Tenant
  #====================================
  # Maestrano Enterprise Tenant name
  mattr_accessor :app_name
  @@tenant_name = 'Maestrano Enterprise'

  # Maestrano Enterprise Default Country
  mattr_accessor :app_country
  @@app_country = 'US'

  # Maestrano Enterprise Default Currency
  mattr_accessor :app_currency
  @@app_currency = 'USD'

  # Maestrano Enterprise Tenant ID
  mattr_accessor :tenant_id
  @@tenant_id = nil

  # Maestrano Enterprise Tenant Key
  mattr_accessor :tenant_key
  @@tenant_key = nil

  #====================================
  # Impac
  #====================================
  mattr_accessor :impac_api_host
  @@impac_api_host = 'https://api-impac-uat.maestrano.io'

  mattr_accessor :impac_api_root_path
  @@impac_api_root_path = "/api/v1"

  #====================================
  # Enterprise API
  #====================================
  # The Maestrano Enterprise API Host
  mattr_accessor :mno_api_host
  @@mno_api_host = "https://api-enterprise.maestrano.com"

  # The Maestrano Enterprise API base path
  mattr_accessor :mno_api_root_path
  @@mno_api_root_path = "/v1"

  # Hold the Her API configuration (see configure_api method)
  mattr_reader :mnoe_api_v1
  @@mnoe_api_v1 = nil

  # Hold the Maestrano enterprise router (redirection to central enterprise platform)
  mattr_reader :router
  @@router = Router.new


  #====================================
  # Emailing
  #====================================
  # Mandrill Key for sending emails
  # Points to the default maestrano enterprise account
  mattr_accessor :mandrill_key
  @@mandrill_key = 'QcrLVdukhBi7iYrTeWHRPQ'

  # The support email address
  mattr_accessor :support_email
  @@support_email = "support@example.com"

  # Default sender name
  mattr_accessor :default_sender_name
  @@default_sender_name = nil

  # Default sender email
  mattr_accessor :default_sender_email
  @@default_sender_email = "no-reply@example.com"

  #====================================
  # Third Party Plugins
  #====================================
  mattr_accessor :google_tag_container
  @@google_tag_container = nil

  #====================================
  # Layout & Styling
  #====================================
  # Nested structure defining the general style of the application
  mattr_accessor :styleguide
  mattr_accessor :style
  @@styleguide = nil
  @@style = nil

  #====================================
  # Marketplace
  #====================================
  # List of applications that should be offered on
  # the marketplace
  mattr_accessor :marketplace_listing
  @@marketplace_listing = [
    "allocpsa",
    "bugzilla",
    "collabtive",
    "dolibarr",
    "drupal",
    "egroupware",
    "eventbrite",
    "feng-office",
    "front-accounting",
    "group-office",
    "hummingbirdshare",
    "interleave",
    "jenkins",
    "joomla",
    "limesurvey",
    "mantisbt",
    "megaventory",
    "moodle",
    "myob",
    "office-365",
    "opendocman",
    "openerp",
    "openx",
    "orangehrm",
    "pentaho-bi",
    "phreedom",
    "plandora",
    "prestashop",
    "processmaker",
    "projectpier",
    "quickbooks",
    "receipt-bank",
    "signmee",
    "simpleinvoices",
    "so-planning",
    "spotlight-reporting",
    "sugarcrm",
    "timetrex",
    "vtiger6",
    "wordpress"
  ]

  #====================================
  # Module Methods
  #====================================

  # Always reload style in development
  def self.style
    self.configure_styleguide if Rails.env.development?
    @@style
  end

  # Default way to setup MnoEnterprise. Run rails generate mno-enterprise:install to create
  # a fresh initializer with all configuration values.
  def self.configure
    yield self
    self.configure_styleguide
    self.configure_api
  end

  # Create a JSON web token with the provided payload
  # E.g.: MnoEnterprise.jwt({ user_id: 'usr-427431' })
  def self.jwt(payload)
    secret = "#{self.tenant_id}:#{self.tenant_key}"
    iat = Time.now.utc.to_i

    JWT.encode(payload.merge(
      iss: MnoEnterprise.tenant_id,
      iat: iat,
      jit: Digest::MD5.hexdigest("#{secret}:#{iat}")
    ), secret)
  end

  private
    # Return the options to use in the setup of the API
    def self.api_options
      { url: "#{URI.join(@@mno_api_host,@@mno_api_root_path).to_s}", send_only_modified_attributes: true }
    end

    # Load the provided styleguide hash into nested structure or load a default one
    def self.configure_styleguide
      # Load default gem configuration
      hash = YAML.load(File.read(File.join(MnoEnterprise::Engine.root,'config','styleguide.yml')))

      # Load default app styleguide, unless explicitly specified
      default_path = File.join(Rails.root,'config','mno_enterprise_styleguide.yml')
      if !@@styleguide && File.exists?(default_path)
        @@styleguide = YAML.load(File.read(default_path))
      end

      @@styleguide.is_a?(Hash) && hash.deep_merge!(@@styleguide)
      @@style = DeepStruct.wrap(hash)
    end

    # Configure the Her for Maestrano Enterprise API V1
    def self.configure_api
      # Configure HER for Maestrano Enterprise Endpoints
      @@mnoe_api_v1 = Her::API.new
      @@mnoe_api_v1.setup self.api_options  do |c|
        # Request
        c.use Faraday::Request::BasicAuthentication, @@tenant_id, @@tenant_key
        c.use Faraday::Request::UrlEncoded

        # Response
        c.use Her::Middleware::MnoeApiV1ParseJson

        # Adapter
        c.use Faraday::Adapter::NetHttp
      end
    end

end
