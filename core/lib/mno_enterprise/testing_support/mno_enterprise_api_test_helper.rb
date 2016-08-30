module MnoEnterpriseApiTestHelper
  
  # Take a resource and transform it into a Hash describing
  # the resource as if it had been returned by the MnoEnterprise
  # API server
  def from_api(res)
    { data: serialize_type(res), metadata: {pagination: {count: entity_count(res)}} }
  end
  
  def serialize_type(res)
    case
    when res.kind_of?(Array)
      return res.map { |e| serialize_type(e) }
    when res.kind_of?(MnoEnterprise::BaseResource)
      hash = res.attributes.dup
      hash.each do |k,v|
        hash[k] = serialize_type(v)
      end
      return hash
    when res.kind_of?(Hash)
      hash = res.dup
      hash.each do |k,v|
        hash[k] = serialize_type(v)
      end
      return hash
    when res.kind_of?(Money)
      return { cents: res.cents, currency: res.currency_as_string }
    when res.respond_to?(:iso8601)
      return res.iso8601
    else
      return res
    end
  end

  def entity_count(res)
    case
    when res.kind_of?(Array)
      return res.count
    when res.kind_of?(Hash)
      return res.count
    else
      return 1
    end
  end
  
  # Reset all API stubs.
  # Called before each test (see spec_helper)
  def api_stub_reset
    @_api_stub = nil
    @_stub_list = {}
    api_stub_configure(Her::API.new)
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
    real_opts = klass
    if klass.is_a?(Class)
      warn("DEPRECATION WARNING: api_stub_for(MyClass,{ some: 'opts'}) is deprecated. Please use api_stub_for({ some: 'opts' }) from now on")
      real_opts = opts
    end
    
    set_api_stub
    api_stub_add(real_opts)
    api_stub_configure(@_api_stub)
  end
  
  private
    # Set a stub api on the provider class
    def set_api_stub
      return @_api_stub if @_api_stub
      @_api_stub = Her::API.new
      allow(MnoEnterprise::BaseResource).to receive(:her_api).and_return(@_api_stub = Her::API.new)
      @_api_stub
    end
  
    # Add a stub to the api
    # E.g.:
    # { 
    #   path: '/users/popular',
    #   code: 200,
    #   response: [{ id: 1, name: "Tobias Fünke" }, { id: 2, name: "Lindsay Fünke" }]
    # }
    def api_stub_add(orig_opts)
      @_stub_list ||= {}
      opts = orig_opts.dup
      
      # Expand options so that: { put: '/path' } becomes { path: '/path', method: :put }
      unless opts[:method] && opts[:path]
        [:get,:put,:post,:delete].each do |verb|
          if path = opts.delete(verb)
            opts[:path] = path
            opts[:method] = verb
          end
        end
      end
      
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
        c.use Her::Middleware::MnoeApiV1ParseJson
        c.use Her::Middleware::MnoeRaiseError

        # Add stubs on the test adapter
        c.use MnoeFaradayTestAdapter do |receiver|
          @_stub_list.each do |key,stub|
            params = stub[:params] && stub[:params].any? ? "?#{stub[:params].to_param}" : ""
            path = "#{stub[:path]}#{params}"
            
            receiver.send(stub[:method] || :get,path) { |env|
              body = Rack::Utils.parse_nested_query(env.body)
              
              # respond_with takes a model in argument and automatically responds with
              # a json representation of the model
              # If the action is an update, it attempts to update the model
              if model = stub[:respond_with]
                model.assign_attributes(body['data']) if stub[:method] == :put && model.respond_to?(:assign_attributes) && body['data']
                resp = from_api(model)
              else
                if stub[:response].is_a?(Proc)
                  args = stub[:response].arity > 0 ? [body] : []
                  resp = stub[:response].call(*args)
                else
                  resp = stub[:response] || {}
                end
              end
              
              # Response code
              if stub[:code].is_a?(Proc)
                args = stub[:code].arity > 0 ? [body] : []
                resp_code = stub[:code].call(*args)
              else
                resp_code = stub[:code] || 200
              end
                 
              
              [resp_code, {}, resp.to_json] 
            }
          end
        end
      end
    end
end