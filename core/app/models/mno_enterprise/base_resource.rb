require 'json_api_client'
module MnoEnterprise
  class BaseResource < ::JsonApiClient::Resource
    include ActiveModel::Callbacks
    self.site = URI.join(MnoEnterprise.api_host, MnoEnterprise.mno_api_v2_root_path).to_s
    self.parser = JsonApiClientExtension::CustomParser

    define_callbacks :update
    define_callbacks :save

    # retrieve all the elements
    def self.fetch_all(list = self.where)
      result = []
      loop do
        result.push(*list.to_a)
        break unless (list.pages.links||{})['next']
        list = list.pages.next
      end
      result
    end

    # TODO: Replace limit and offset parameters by page and per_page
    def self.apply_query_params(params, relation = self.where)
      relation.paginate(page: 1 + params[:offset].to_i/params[:limit].to_i, per_page: params[:limit].to_i) if params[:limit] && params[:offset]
      relation.order(adapt_order_by(params[:order_by])) if params[:order_by]
      relation.where(params[:where]) if params[:where]
      relation
    end

    def self.adapt_order_by(input)
      partition = input.rpartition('.')
      field = partition.first
      order = partition.last
      return '-' + field if (order == 'desc')
      return field if (order == 'asc')
      input
    end

    def self.find_one!(id, *included)
      self.includes(included).find(id).first
    end

    def self.find_one(id, *included)
      find_one!(id, included)
    rescue JsonApiClient::Errors::NotFound
      nil
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

    def save!
      save
      raise "Could not save: Attributes #{self.attributes}, Errors: #{self.full_messages}" unless self.errors.empty?
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
      if self.id
        self.class.find_one(self.id, included)
      else
        raise "Can't load_required #{self.class} id is nil"
      end
    end

    def reload
      load_required
    end

    def ==(o)
      o.class == self.class && o.attributes == attributes
    end

  end
end

LocaleMiddleware = Struct.new(:app) do
  def call(env)
    env.url.query = add_query_param(env.url.query, "_locale", I18n.locale)
    app.call env
  end

  def add_query_param(query, key, value)
    query = query.to_s
    query << "&" unless query.empty?
    query << "#{Faraday::Utils.escape key}=#{Faraday::Utils.escape value}"
  end
end

MnoEnterprise::BaseResource.connection do |connection|
  connection.use Faraday::Request::BasicAuthentication, MnoEnterprise.tenant_id, MnoEnterprise.tenant_key

  connection.use LocaleMiddleware

  # log responses
  connection.use Faraday::Response::Logger if Rails.env.development?
end
