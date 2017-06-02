# frozen_string_literal: true
module MnoEnterprise
  class ConfigController < ApplicationController
    protect_from_forgery except: :show

    def show
      # Allow public caching
      expires_in 0, public: true, must_revalidate: true

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
  end
end
