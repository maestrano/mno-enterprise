require 'prawn'
require 'prawn/table'
require 'money'
require 'deepstruct'
require 'jwt'
require 'countries'
require 'cancancan'
require 'devise'
require 'devise/strategies/remote_authenticatable'
require 'devise_extension'
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
require "faraday_middleware"
require "mno_enterprise/engine"

require 'mno_enterprise/database_extendable'

# Settings
require 'config'
require 'figaro'

require "mandrill_client"

require 'accountingjs_serializer'

module MnoEnterprise

  #==================================================================
  # MnoEnterprise Router
  # Centralizes all URLs available on the Maestrano Enterprise side
  #==================================================================
  class Router
    attr_accessor :terms_url

    # Customise after_sign_out url
    attr_accessor :after_sign_out_url

    attr_accessor :dashboard_path

    def dashboard_path
      @dashboard_path || '/dashboard/'
    end

    def terms_url
      @terms_url || '#'
    end

    def admin_path
      @admin_path || '/admin/'
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

    # @deprecated Impac is now configured through Settings
    def impac_root_url
      warn '[DEPRECATION] `impac_root_url` is deprecated. Impac is now configured in the frontend through `Settings`.'
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
  # @deprecated Impac is now configured through Settings

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

  # The Maestrano Enterprise API Private Host
  # Used within VPCs for making calls to mno_api using
  # private DNS
  mattr_accessor :mno_api_private_host
  @@mno_api_private_host = nil

  # The Maestrano Enterprise API base path
  mattr_accessor :mno_api_root_path
  @@mno_api_root_path = "/api/mnoe/v1"

  # Hold the Her API configuration (see configure_api method)
  mattr_reader :mnoe_api_v1
  @@mnoe_api_v1 = nil

  # Hold the Maestrano enterprise router (redirection to central enterprise platform)
  mattr_reader :router
  @@router = Router.new


  #====================================
  # Emailing
  #====================================
  # @deprecated: Use ENV['MANDRILL_API_KEY']
  # Mandrill Key for sending emails
  def self.mandrill_key
    warn "[DEPRECATION] `mandrill_key` is deprecated. Use `ENV['MANDRILL_API_KEY']`."
    @@mandrill_key
  end
  def self.mandrill_key=(mandrill_key)
    warn "[DEPRECATION] `mandrill_key` is deprecated. Use `ENV['MANDRILL_API_KEY']`."
    @@mandrill_key = mandrill_key
  end
  @@mandrill_key = nil

  # Adapter used to send emails
  # Default to :mandrill
  mattr_reader(:mail_adapter) { Rails.env.test? ? :test : :mandrill }
  def self.mail_adapter=(adapter)
    @@mail_adapter = adapter
    MnoEnterprise::MailClient.adapter = self.mail_adapter
  end

  # The support email address
  mattr_accessor :support_email
  @@support_email = "support@example.com"

  # Default sender name
  mattr_accessor :default_sender_name
  @@default_sender_name = nil

  # Default sender email
  mattr_accessor :default_sender_email
  @@default_sender_email = "no-reply@example.com"

  #===============================================
  # Optional Modules
  #===============================================
  # Angular CSRF
  mattr_accessor :include_angular_csrf
  @@include_angular_csrf = false

  # I18n
  mattr_accessor :i18n_enabled
  @@i18n_enabled = false

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
  @@marketplace_listing = nil

  #====================================
  # Impac! widgets templates listing
  #====================================
  # List of widget templates that should be offered on Impac!
  # if nil, all widget templates available will be offered
  mattr_accessor :widgets_templates_listing
  @@widgets_templates_listing = nil

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

    # Mail config
    # We can't use the setter before MailClient is loaded
    self.mail_adapter = self.mail_adapter
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
      api_host = @@mno_api_private_host || @@mno_api_host
      {
          url: "#{URI.join(api_host,@@mno_api_root_path).to_s}",
          send_only_modified_attributes: true
      }
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
        # c.use Faraday::Request::UrlEncoded
        c.request :json

        # Instrumentation in development
        c.use :instrumentation if Rails.env.development?

        # Response
        c.use Her::Middleware::MnoeApiV1ParseJson

        # Adapter
        c.use Faraday::Adapter::NetHttpNoProxy
      end
    end
end

# Instrumentation in development
ActiveSupport::Notifications.subscribe('request.faraday') do |name, starts, ends, _, env|
  url = env[:url]
  http_method = env[:method].to_s.upcase
  duration = ends - starts
  Rails.logger.debug '[%s] %s %s (%.3f s)' % [url.host, http_method, url.request_uri, duration]
end if Rails.env.development?
