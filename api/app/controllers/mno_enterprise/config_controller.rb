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
      Array(Settings.system.i18n.available_locales).map do |locale|
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
  end
end
