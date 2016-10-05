module MnoEnterprise
  class ImpacClient
    include HTTParty

    def self.host
      "#{Settings.impac.protocol}://#{Settings.impac.host}"
    end

    def self.endpoint_url(endpoint, params)
      "#{File.join(host,endpoint)}?#{params.to_query}"
    end

    def self.send_get(endpoint, params, opts={})
      url = endpoint_url(endpoint, params)
      get(url, opts)
    end

  end
end
