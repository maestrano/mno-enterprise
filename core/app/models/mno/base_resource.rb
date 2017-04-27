require 'json_api_client'
module Mno
  class BaseResource < ::JsonApiClient::Resource
    self.site = URI.join(MnoEnterprise.api_host, MnoEnterprise.mno_api_v2_root_path).to_s


    #add missing method
    def update_attribute(name, value)
      self.update_attributes(Hash[name, value])
    end

    def save(*args)
      super()
    end

    def self.to_adapter
      @_to_adapter ||= JsonApiClient::OrmAdapter.new(self)
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

    def new?
      id.nil?
    end


    def max_updated_column_timestamp(timestamp_names = [:updated_at])
      timestamp_names
        .map { |attr| self[attr] }
        .compact
        .map(&:to_time)
        .max
    end

  end
end

Mno::BaseResource.connection do |connection|
  connection.use Faraday::Request::BasicAuthentication, MnoEnterprise.tenant_id, MnoEnterprise.tenant_key #

  # log responses
  connection.use Faraday::Response::Logger
end
