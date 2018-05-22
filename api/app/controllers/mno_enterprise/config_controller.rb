# frozen_string_literal: true
module MnoEnterprise
  class ConfigController < ApplicationController
    protect_from_forgery except: :show

    def show
      # Allow public caching
      expires_in 0, public: true, must_revalidate: true

      @available_locales = available_locales

      respond_to do |format|
        format.js { self.response_body = minify(render_to_string) }
        format.json { render json: Settings.config_timestamp }
      end
    end

    protected

    # Minify JS in non dev environments
    def minify(content)
      Rails.cache.fetch(MnoEnterprise::TenantConfig::CACHE_KEY) do
        if Rails.env.development? || Rails.env.test?
          content
        else
          Uglifier.new.compile(content)
        end
      end
    end

    def available_locales
      available_locales = if Settings.system.i18n.enabled
        Settings.system.i18n.available_locales
      else
        set_default_locale
        Settings.system.i18n.preferred_locale
      end
      Array(available_locales).map do |locale|
        name = begin
          I18n.t('language', locale: locale)
        rescue I18n::InvalidLocale
          locale.to_s
        end
        {
          id: locale.to_s,
          name: name,
          flag: ''
        }
      end
    end

    def set_default_locale
      I18n.default_locale = Settings.system.i18n.preferred_locale
    end
  end
end
