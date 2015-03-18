module MnoEnterprise
  class BaseResource
    #extend ActiveSupport::Concern
    include Her::Model
    use_api MNO_ENTERPRISE_API_V1
    
    attributes :id
    
    # Emulate ActiveRecord for Her
    def read_attribute(attr_name)
      get_attribute(attr_name)
    end
    
    # Emulate ActiveRecord for Her
    def write_attribute(attr_name, value)
      assign_attributes(attr_name => value)
    end
    alias []= write_attribute
    
    # Emulate ActiveRecord for Her
    def save(options={})
      perform_validations(options) ? super() : false
    end
    
    # Emulate ActiveRecord for Her
    def save!(options={})
      perform_validations(options) ? super() : raise_record_invalid
    end
    
    protected
      # Emulate ActiveRecord for Her
      def raise_record_invalid
        raise(Her::Errors::ResourceInvalid.new(self))
      end

      # Emulate ActiveRecord for Her
      def perform_validations(options={}) # :nodoc:
        options[:validate] == false || valid?(options[:context])
      end
  end
end
