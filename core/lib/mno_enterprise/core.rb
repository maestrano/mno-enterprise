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
require "active_model"
require "httparty"
require "json_api_client"
require "json_api_client_extension/json_api_client_orm_adapter"
require "json_api_client_extension/validations/remote_uniqueness_validation"
require "json_api_client_extension/custom_parser"
require 'faraday/locale_middleware'
require "mno_enterprise/engine"
require 'mno_enterprise/database_extendable'
require 'mno_enterprise/mno_enterprise_version'

# Settings
require 'config'
require 'json-schema'

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
      @terms_url || '/mnoe/terms'
    end

    def admin_path
      @admin_path || '/admin/'
    end

    def launch_url(id,opts = {})
      host_url("/launch/#{id}",opts)
    end

    def deeplink_url(organization_id,entity_type,entity_id,opts = {})
      host_url("/deeplink/#{organization_id}/#{entity_type}/#{entity_id}", opts)
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
  # Adapter used to manage the app
  # This shouldn't need to be set manually
  mattr_reader(:platform_adapter) do
    if Rails.env.test?
      :test
    elsif ENV['SELF_NEX_API_KEY'].present? && Gem.loaded_specs.has_key?('nex_client')
      :nex
    else
      :local
    end
  end
  def self.platform_adapter=(adapter)
    @@platform_adapter = adapter
    MnoEnterprise::SystemManager.adapter = self.platform_adapter
  end

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

  mattr_accessor :mno_api_v2_root_path
  @@mno_api_v2_root_path = "/api/mnoe/v2"

  # Hold the Maestrano enterprise router (redirection to central enterprise platform)
  mattr_reader :router
  @@router = Router.new

  #====================================
  # Emailing
  #====================================
  # Adapter used to send emails
  # Default to :mandrill
  mattr_reader(:mail_adapter) { Rails.env.test? ? :test : :smtp }
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

  mattr_accessor :intercom_app_id
  @@intercom_app_id = nil

  mattr_accessor :intercom_api_secret
  @@intercom_api_secret = nil

  mattr_accessor :intercom_token
  @@intercom_token = nil

  # Define if Intercom is enabled. Only if the gem intercom is present
  def self.intercom_enabled?
    defined?(::Intercom) && intercom_app_id.present? && intercom_token.present?
  end

  #====================================
  # Layout & Styling
  #====================================
  # Nested structure defining the general style of the application
  mattr_accessor :styleguide
  mattr_accessor :style
  @@styleguide = nil
  @@style = nil

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

  def self.api_host
   @@mno_api_private_host || @@mno_api_host
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

    # Configure JsonApiClient for Maestrano Enterprise API V2
    def self.configure_api
      MnoEnterprise::BaseResource.site = URI.join(api_host, @@mno_api_v2_root_path).to_s

      MnoEnterprise::BaseResource.connection do |connection|
        connection.use Faraday::Request::BasicAuthentication, @@tenant_id, @@tenant_key

        connection.use Faraday::LocaleMiddleware

        if Rails.env.development?
          # log responses
          connection.use Faraday::Response::Logger

          # Instrumentation (see below for the subscription)
          connection.use FaradayMiddleware::Instrumentation if Rails.env.development?
        end
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
