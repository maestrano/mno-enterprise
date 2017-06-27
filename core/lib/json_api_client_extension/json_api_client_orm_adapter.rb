require 'orm_adapter'

module JsonApiClient
  module Errors
    class ResourceNotFound < StandardError
    end
  end

  class OrmAdapter < ::OrmAdapter::Base
    # get a list of column names for a given class
    def column_names
      @columns ||= klass.instance_methods.grep(/_will_change!$/).map { |e| e.to_s.gsub('_will_change!','') }
    end

    # @see OrmAdapter::Base#get!
    def get!(id)
      res = klass.includes(:deletion_requests, :organizations, :orga_relations, :dashboards).find(wrap_key(id)).first
      raise JsonApiClient::Errors::ResourceNotFound, "resource not found" unless res
      res
    end

    # @see OrmAdapter::Base#get
    def get(id)
      res = klass.includes(:deletion_requests, :organizations, :orga_relations, :dashboards).find(wrap_key(id))
      error = res&.errors&.first
      if(error && error.code != '404')
        raise error.detail
      end
      res.first
    end

    # @see OrmAdapter::Base#find_first
    def find_first(options = {})
      find_all(options).first
    end

    # @see OrmAdapter::Base#find_all
    def find_all(options = {})
      klass.where(options)
    end

    # @see OrmAdapter::Base#create!
    def create!(attributes = {})
      klass.create!(attributes)
    end

    # @see OrmAdapter::Base#destroy
    def destroy(object)
      object.destroy if valid_object?(object)
    end
  end

end
