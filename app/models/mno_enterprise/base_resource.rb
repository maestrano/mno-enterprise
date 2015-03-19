module MnoEnterprise
  class BaseResource
    include Her::Model
    #parse_root_in_json :data
    include_root_in_json :data
    use_api MnoEnterprise.mnoe_api_v1
    
    
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
