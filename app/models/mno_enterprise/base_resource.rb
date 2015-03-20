# TODO: spec the ActiveRecord behaviour
# - processing of remote errors
# - response parsing (using data: [] format)
# - save methods
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
      if perform_validations(options) 
        ret = super()
        process_response_errors
        ret
      else
        false
      end
    end
    
    # Emulate ActiveRecord for Her
    def save!(options={})
      if perform_validations(options) 
        ret = super()
        process_response_errors
        raise_record_invalid
      else
        false
      end
    end
    
    # Emulate ActiveRecord for Her
    def reload(options = nil)
      @attributes.update(self.class.find(self.id)).instance_variable_get('@attributes')
    end
    
    protected
      # Process errors from the servers and add them to the
      # model
      # Servers are returned using the jsonapi format
      # E.g.: 
      # errors: [
      #   {
      #     :id=>"f720ca10-b104-0132-dbc0-600308937d74", 
      #     :href=>"http://maestrano.github.io/enterprise/#users-users-list-post",
      #     :status=>"400",
      #     :code=>"name-can-t-be-blank",
      #     :title=>"Name can't be blank",
      #     :detail=>"Name can't be blank"
      #   }
      # ]
      def process_response_errors
        if self.response_errors && self.response_errors.any?
          self.response_errors.each do |error|
            self.errors[:base] << error[:title]
          end
        end
      end
      
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
