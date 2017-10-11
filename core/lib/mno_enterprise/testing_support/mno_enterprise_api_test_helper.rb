module MnoEnterpriseApiTestHelper
  MOCK_OPTIONS = {
    headers: {
      'Accept' => 'application/vnd.api+json',
      'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Content-Type' => 'application/vnd.api+json'
    },
    basic_auth: [MnoEnterprise.tenant_id, MnoEnterprise.tenant_key]
  }

  JSON_API_RESULT_HEADERS = {content_type: 'application/vnd.api+json'}

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

  def stub_audit_events
    stub_api_v2(:post, '/audit_events')
  end

  def stub_user(user)
    stub_api_v2(:get, "/users/#{user.id}", user, %i(deletion_requests organizations orga_relations dashboards teams sub_tenant))
  end

  def api_v2_url(suffix, included = [], params = {})
    url = MnoEnterprise::BaseResource.site + suffix
    params = params.merge(include: included.join(',')) if included.any?
    url+="?#{params.to_query}" if params.any?
    url
  end

  # Emulate the answer returned by the API V2. Returns a subset of json defined by the jsonapi-resources spec, so that it can be read by json api client
  def stub_api_v2(method, suffix, entity = nil, included = [], params = {})
    params.reverse_merge!(_locale: I18n.locale)
    url = api_v2_url(suffix, included, params)
    stub = stub_request(method, url).with(MOCK_OPTIONS)
    stub.to_return(status: 200, body: from_apiv2(entity, included).to_json, headers: JSON_API_RESULT_HEADERS) if entity
    stub
  end

  def stub_api_v2_error(method, suffix, error_code = 400, error = 'error on the field')
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
    stub.to_return(status: error_code, body: body, headers: JSON_API_RESULT_HEADERS)
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

  def serialize_relation(r, included_entities, inclusions = [])
    included_entities[entity_key(r)] = [r, inclusions]
    { type: type(r), id: r.id }
  end

  def serialize_data(entity, included, included_entities)
    relationships = included.map do |field|
      # Split multi-level fieds such as includes=app_instances.app
      fields = field.to_s.split('.')

      # Call first level of association
      relations = entity.send(fields.shift)
      next unless relations

      data = if relations.kind_of?(Array)
               relations.map { |r| serialize_relation(r, included_entities, fields) }
             else
               serialize_relation(relations, included_entities, fields)
             end
      [field, { data: data }]
    end.compact.to_h

    {
      id: entity.id,
      type: type(entity),
      attributes: serialize_type(entity),
      relationships: relationships
    }
  end

  # Take a resource and transform it into a Hash describing
  # the resource as if it had been returned by the MnoEnterprise
  # API server
  def from_apiv2(entity, included)
    included_entities = {}
    data = if entity.kind_of?(Array)
             entity.map{|e| serialize_data(e, included, included_entities)}
           else
             serialize_data(entity, included, included_entities)
           end

    # Generate first and second level inclusions. E.g. includes='app_instances.app'
    # The second level entities get added to the included_entities hash
    included_entities.values.each { |obj, inclusions| serialize_data(obj, inclusions, included_entities) }

    {
      data: data,
      meta: {
        record_count: entity_count(entity)
      },
      included: included_entities.values.map { |obj, inclusions| serialize_data(obj, inclusions, included_entities) }
    }
  end
end
