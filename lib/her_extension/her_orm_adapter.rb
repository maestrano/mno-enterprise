require 'orm_adapter'

# TODO: extract in gem orm_apdater-her
module Her
  module Errors
    class ResourceNotFound < StandardError
    end
  end
  
  module Model
    module ClassMethods
      include OrmAdapter::ToAdapter
    end
    
    class OrmAdapter < ::OrmAdapter::Base
      # get a list of column names for a given class
      def column_names
        @columns ||= klass.instance_methods.grep(/_will_change!$/).map { |e| e.to_s.gsub('_will_change!','') }
      end

      # @see OrmAdapter::Base#get!
      def get!(id)
        res = klass.find(wrap_key(id))
        raise Her::Errors::ResourceNotFound, "resource not found" unless res
        res
      end

      # @see OrmAdapter::Base#get
      def get(id)
        klass.find(wrap_key(id))
      end

      # @see OrmAdapter::Base#find_first
      def find_first(options = {})
        klass.where(options).limit(1).first
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
end