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
      # TODO: cache and purge cache when initializing settings
      # Rails.cache.fetch(MnoEnterprise::Tenant.current) do
        if Rails.env.development? || Rails.env.test?
          content
        else
          Uglifier.new.compile(content)
        end
      # end
    end

    def available_locales
      # TODO: initializer and freeze?
      Array(Settings.system.i18n.available_locales).map do |locale|
        {
          id: locale.to_s,
          name: I18n.t('language', locale: locale),
          flag: ''
        }
      end
    end
  end
end
