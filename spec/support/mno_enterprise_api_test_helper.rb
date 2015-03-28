module MnoEnterpriseApiTestHelper
  
  # Take a resource and transform it into a Hash describing
  # the resource as if it had been returned by the MnoEnterprise
  # API server
  def from_api(res)
    case
    when res.kind_of?(Array)
      return res.map { |e| from_api(e) }
    when res.kind_of?(MnoEnterprise::BaseResource)
      hash = res.attributes.dup
      hash.each do |k,v|
        hash[k] = from_api(v)
      end
      return hash
    when res.kind_of?(Hash)
      hash = res.dup
      hash.each do |k,v|
        hash[k] = from_api(v)
      end
      return hash
    else
      return res
    end
  end
  
  # Reset all API stubs.
  # Called before each test (see spec_helper)
  def api_stub_reset
    @_api_stub = {}
    @_stub_list = {}
  end
  
  # Example usage:
  # 
  # Without opts, it yields a faraday stub object which you can configure
  # manually:
  #
  # You can also pass the response stub via opts
  # api_stub_for(User, 
  #   path: '/users/popular', 
  #   response: [{ id: 1, name: "Tobias Fünke" }, { id: 2, name: "Lindsay Fünke" }]
  # )
  #
  # You can also specify the response code:
  # api_stub_for(User, 
  #   path: '/users/popular',
  #   code: 200,
  #   response: [{ id: 1, name: "Tobias Fünke" }, { id: 2, name: "Lindsay Fünke" }]
  # )
  def api_stub_for(klass, opts = {})
    api = set_api_stub(klass)
    api_stub_add(opts)
    api_stub_configure(api)
  end
  
  private
    # Set a stub api on the provider class
    def set_api_stub(klass)
      @_api_stub ||= {}
      unless @_api_stub[klass.to_s]
        @_api_stub[klass.to_s] = Her::API.new
        klass.use_api @_api_stub[klass.to_s]
      end
    
      @_api_stub[klass.to_s]
    end
  
    # Add a stub to the api
    # E.g.:
    # { 
    #   path: '/users/popular',
    #   code: 200,
    #   response: [{ id: 1, name: "Tobias Fünke" }, { id: 2, name: "Lindsay Fünke" }]
    # }
    def api_stub_add(opts)
      @_stub_list ||= {}
      key = opts.to_param
      @_stub_list[key] = opts
    end
  
    # Configure the api and apply a list of stubs
    def api_stub_configure(api)
      # This block should match the her.rb initializer
      api.setup MnoEnterprise.send(:api_options).merge(url: "http://localhost:65000") do |c|
        # Request
        c.use Faraday::Request::BasicAuthentication, MnoEnterprise.tenant_id, MnoEnterprise.tenant_key
        c.use Faraday::Request::UrlEncoded

        # Response
        c.use Her::Middleware::DefaultParseJSON
      
        # Add stubs on the test adapter
        c.adapter(:test) do |receiver|
          @_stub_list.each do |key,stub|
            params = stub[:params] && stub[:params].any? ? "?#{stub[:params].to_param}" : ""
            path = "#{stub[:path]}#{params}"
            receiver.send(stub[:method] || :get,path) { |env|
              puts "Consumed stub: #{stub}"
              [stub[:code] || 200, {}, (stub[:response] || {}).to_json] 
            }
          end
        end
      end
    end
end