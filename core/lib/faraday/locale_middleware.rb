module Faraday
  class LocaleMiddleware < Faraday::Middleware
    def call(env)
      env.url.query = add_query_param(env.url.query, "_locale", I18n.locale)
      @app.call env
    end

    def add_query_param(query, key, value)
      query = query.to_s
      query << "&" unless query.empty?
      query << "#{Faraday::Utils.escape key}=#{Faraday::Utils.escape value}"
    end
  end
end
