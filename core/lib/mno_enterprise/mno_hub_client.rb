module MnoEnterprise
  class MnoHubClient
    include HTTParty
    base_uri URI.join(MnoEnterprise.api_host, MnoEnterprise.mno_api_v2_root_path).to_s
    basic_auth MnoEnterprise.tenant_id, MnoEnterprise.tenant_key
    headers 'Accept' => 'application/vnd.api+json', 'Content-Type' => 'application/vnd.api+json'

    # Debugging
    # debug_output $stdout
    logger Rails.logger

    def initialize
    end

    def get(endpoint, params = {})
      options = filter_params(params)
      path = File.join('', endpoint) # Leading /
      self.class.get(path, options)
    end

    def post(endpoint, options = {})
      path = File.join('', endpoint) # Leading /
      self.class.post(path, options)
    end

    def patch(endpoint, options = {})
      path = File.join('', endpoint) # Leading /
      self.class.patch(path, options)
    end

    def delete(endpoint, options = {})
      path = File.join('', endpoint) # Leading /
      self.class.delete(path, options)
    end

    private

    # Filter params to only forward the params we need
    # TODO: move in controller?
    def filter_params(params)
      # options[:query] = options[:query].inject({}) { |h, q| h[q[0].to_s.camelize] = q[1]; h }
      {
        query: params.permit(
          :include,
          page: [:number, :size]
        )
      }
    end
  end
end
