module MnoEnterpriseApiTestHelper
  
  # Example usage:
  # 
  # Without opts, it yields a faraday stub object which you can configure
  # manually:
  # stub_api_for(User) do |stub|
  #   stub.get("/users/popular") { |env| [200, {}, [{ id: 1, name: "Tobias Fünke" }, { id: 2, name: "Lindsay Fünke" }].to_json] }
  # end
  #
  # You can also pass the response stub via opts
  # stub_api_for(User, 
  #   path: '/users/popular', 
  #   response: [{ id: 1, name: "Tobias Fünke" }, { id: 2, name: "Lindsay Fünke" }]
  # )
  #
  # You can also specify the response code:
  # stub_api_for(User, 
  #   path: '/users/popular',
  #   code: 200,
  #   response: [{ id: 1, name: "Tobias Fünke" }, { id: 2, name: "Lindsay Fünke" }]
  # )
  def stub_api_for(klass, opts = {})
    klass.use_api (api = Her::API.new)

    # This block should match the her.rb initializer
    api.setup url: "http://api.example.com" do |c|
      # Request
      c.use Faraday::Request::BasicAuthentication, MnoEnterprise.tenant_id, MnoEnterprise.tenant_key
      c.use Faraday::Request::UrlEncoded
  
      # Response
      c.use Her::Middleware::DefaultParseJSON

      # Adapter
      c.use Faraday::Adapter::NetHttp
      
      if opts[:path]
        c.adapter(:test) do |stub|
          stub.send(opts[:method] || :get) { |env| [opts[:code] || 200, {}, (opts[:response] || {}).to_json] }
        end
      else
        c.adapter(:test) { |stub| yield(stub) }
      end
    end
  end
  
end