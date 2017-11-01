require 'json_api_client'
module MnoEnterprise

  class BaseResource < ::JsonApiClient::Resource
    include ActiveModel::Callbacks
    include JsonApiClientExtension::HasOneExtension
    self.site = URI.join(MnoEnterprise.api_host, MnoEnterprise.mno_api_v2_root_path).to_s
    self.parser = JsonApiClientExtension::CustomParser

    # == Callbacks ========================================================
    define_callbacks :create
    define_callbacks :update
    define_callbacks :save

    # == Class Methods ========================================================

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

    def self.create!(attributes)
      resource = create(attributes)
      resource.raise_if_errors
      resource
    end

    def self.process_custom_result(result)
      instance = new
      instance.process_custom_result(result)
    end

    # == Instance Methods ========================================================
    # cache of the loaded relations, used in JsonApiClientExtension::HasOneExtension
    def relations
      @relations ||= ActiveSupport::HashWithIndifferentAccess.new
    end

    def process_custom_result(result)
      collect_errors(result.errors)
      raise_if_errors
      result.first
    end

    # add missing method
    def update_attribute(name, value)
      self.update_attributes(Hash[name, value])
    end

    # emulate active record call of callbacks
    def save(*_args)
      callback_kind = new_record? ? :create : :update
      run_callbacks :save do
        run_callbacks callback_kind do
          super()
        end
      end
    end

    def save!
      save
      raise_if_errors
    end

    def update!(attrs = {})
      update(attrs)
      raise_if_errors
    end

    def destroy!
      destroy
      raise_if_errors
    end

    def collect_errors(external_errors)
      external_errors.each do |error|
        if error.source_parameter
          errors.add(self.class.key_formatter.unformat(error.source_parameter), error.title || error.detail)
        else
          errors.add(:base, error.title || error.detail)
        end
      end
    end

    def update_attributes!(attrs = {})
      update_attributes(attrs)
      raise_if_errors
    end

    def raise_if_errors
      raise ResourceError.new(errors) unless errors.empty?
    end

    # emulate active record call of callbacks, a bit different as before_update is called before before_save
    def update_attributes(attrs = {})
      self.attributes = attrs
      save
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
