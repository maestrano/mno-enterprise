require 'json_api_client'
module MnoEnterprise

  class CustomParser < ::JsonApiClient::Parsers::Parser
    def self.parameters_from_resource(params)
      hash = super
      parse_types(hash)
    end

    def self.parse_types(res)
      case res
      when Array
        return res.map { |e| parse_types(e) }
      when Hash
        if res.key?('cents') && res.key?('currency')
          return Money.new(res['cents'], res['currency'])
        else
          hash = res.dup
          hash.each do |k, v|
            hash[k] = parse_types(v)
          end
          return hash
        end
      when String
        if res =~ /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/i
          return Time.iso8601(res)
        end
      end
      res
    end
  end

  class BaseResource < ::JsonApiClient::Resource
    include ActiveModel::Callbacks
    self.site = URI.join(MnoEnterprise.api_host, MnoEnterprise.mno_api_v2_root_path).to_s
    self.parser = CustomParser

    define_callbacks :update
    define_callbacks :save

    # TODO: Replace limit and offset parameters by page and per_page
    def self.apply_query_params(relation, params)
      relation.paginate(page: params[:offset]/params[:limit], per_page: params[:limit]) if params[:limit] && params[:offset]
      relation.order_by(params[:order_by]) if params[:order_by]
      relation.where(params[:where]) if params[:where]
      relation
    end

    def self.find_one(id, *included)
      array = self.includes(included).find(id)
      array[0] if array.any?
    end

    def self.exists?(query)
      self.find(query).any?
    end

    def self.to_adapter
      @_to_adapter ||= JsonApiClient::OrmAdapter.new(self)
    end

    def self.find_by_or_create(attributes)
      where(attributes).first || create(attributes)
    end

    #add missing method
    def update_attribute(name, value)
      self.update_attributes(Hash[name, value])
    end

    # emulate active record call of callbacks
    def save(*args)
      run_callbacks :save do
        super()
      end
    end

    # emulate active record call of callbacks, a bit different as before_update is called before before_save
    def update_attributes(attrs = {})
      self.attributes = attrs
      run_callbacks :update do
        save
      end
    end

    def cache_key(*timestamp_names)
      case
        when new?
          "#{model_name.cache_key}/new"
        when timestamp_names.any?
          timestamp = max_updated_column_timestamp(timestamp_names)
          timestamp = timestamp.utc.to_s(:nsec)
          "#{model_name.cache_key}/#{id}-#{timestamp}"
        when timestamp = max_updated_column_timestamp
          timestamp = timestamp.utc.to_s(:nsec)
          "#{model_name.cache_key}/#{id}-#{timestamp}"
        else
          "#{model_name.cache_key}/#{id}"
      end
    end

    # expire the json view cache(using json.cache! ['v1', @user.cache_key] )
    def expire_view_cache
      Rails.cache.delete_matched("jbuilder/v1/#{model_name.cache_key}/#{id}*")
    end

    def new?
      id.nil?
    end

    def max_updated_column_timestamp(timestamp_names = [:updated_at])
      timestamp_names
        .map { |attr| self[attr] }
        .compact
        .max
    end

    # return a new instance with the required loaded
    def load_required(*included)
      self.class.find_one(self.id, included)
    end

    def ==(o)
      o.class == self.class && o.attributes == attributes
    end

  end
end

MnoEnterprise::BaseResource.connection do |connection|
  connection.use Faraday::Request::BasicAuthentication, MnoEnterprise.tenant_id, MnoEnterprise.tenant_key

  # log responses
  connection.use Faraday::Response::Logger
end
