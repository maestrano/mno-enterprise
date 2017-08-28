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


  # Remove an API stub added with `api_stub_for`
  # This needs to be called with the same options
  def remove_api_stub(opts = {})
    set_api_stub
    api_stub_remove(opts)
    api_stub_configure(@_api_stub)
  end

  # Remove all api stubs
  def clear_api_stubs
    set_api_stub
    @_stub_list = {}
    api_stub_configure(@_api_stub)
  end

  def stub_audit_events
    stub_api_v2(:post, '/audit_events')
  end

  def stub_current_user
    let!(:current_user_stub) { stub_api_v2(:get, "/users/#{user.id}", user, %i(deletion_requests organizations orga_relations dashboards)) }
  end


  def api_v2_url(suffix, included = [], params = {})
    url = MnoEnterprise::BaseResource.site + suffix
    params = params.merge(include: included.join(',')) if included.any?
    url+="?#{params.to_query}" if params.any?
    url
  end

  MOCK_OPTIONS = {
    headers: {
      'Accept' => 'application/vnd.api+json',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type' => 'application/vnd.api+json'
    },
    basic_auth: [MnoEnterprise.tenant_id, MnoEnterprise.tenant_key]
  }

  # Emulate the answer returned by the API V2. Returns a subset of json defined by the jsonapi-resources spec, so that it can be read by json api client
  def stub_api_v2(method, suffix, entity = nil, included = [], params = {})
    params.reverse_merge!(_locale: I18n.locale)
    url = api_v2_url(suffix, included, params)
    stub = stub_request(method, url).with(MOCK_OPTIONS)
    stub.to_return(status: 200, body: from_apiv2(entity, included).to_json, headers: {content_type: 'application/vnd.api+json'}) if entity
    stub
  end

  def stub_api_v2_error(method, suffix, error_code, error)
    url = api_v2_url(suffix, [], _locale: I18n.locale)
    stub = stub_request(method, url).with(MOCK_OPTIONS)
    body = {
      errors: [
        {
          title: error,
          detail: error,
          status: error_code
        }
      ]
    }.to_json
    stub.to_return(status: error_code, body: body, headers: {content_type: 'application/vnd.api+json'})
    stub
  end

  def assert_requested_api_v2(method, suffix, options = {})
    options[:query] = (options[:query] || {}).reverse_merge(_locale: I18n.locale)
    assert_requested(method, MnoEnterprise::BaseResource.site + suffix, options)
  end

  def assert_requested_audit_event
    assert_requested_api_v2(:post, '/audit_events')
  end

  private

    def type(entity)
      entity.class.name.to_s.demodulize.underscore.pluralize
    end

    def entity_key(entity)
      "#{type(entity)}/#{entity.id}"
    end

    def serialize_relation(r, included_entities)
      included_entities[entity_key(r)] = r
      {type: type(r), id: r.id}
    end

    def serialize_data(entity, included, included_entities)
      relationships = included.map { |field|
        next if field.to_s.include? '.'
        relations = entity.send(field)
        next unless relations
        data = if relations.kind_of?(Array)
                 relations.map { |r| serialize_relation(r, included_entities) }
               else
                 serialize_relation(relations, included_entities)
               end
        [field, {data: data}]
      }.compact.to_h
      {
        id: entity.id,
        type: type(entity),
        attributes: serialize_type(entity),
        relationships: relationships
      }
    end

    def from_apiv2(entity, included)
      included_entities = {}
      data = if entity.kind_of?(Array)
               entity.map{|e| serialize_data(e, included, included_entities)}
             else
               serialize_data(entity, included, included_entities)
             end

      {
        data: data,
        meta: {
          record_count: entity_count(entity)
        },
        included: included_entities.values.map{|e| serialize_data(e, [], {})}
      }
    end


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

      expand_options(opts)

      key = opts.to_param
      @_stub_list[key] = opts
    end

    # Remove an API
    # This need to be called with the exact same options as `api_stub_add` was called with
    def api_stub_remove(orig_opts)
      @_stub_list ||= {}
      opts = orig_opts.dup

      expand_options(opts)

      key = opts.to_param
      @_stub_list.delete(key)
    end

    # Expand options so that: { put: '/path' } becomes { path: '/path', method: :put }
    def expand_options(opts)
      # Expand options so that: { put: '/path' } becomes { path: '/path', method: :put }
      unless opts[:method] && opts[:path]
        [:get, :put, :post, :delete].each do |verb|
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
