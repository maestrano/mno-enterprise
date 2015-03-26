# TODO: spec the ActiveRecord behaviour
# - processing of remote errors
# - response parsing (using data: [] format)
# - save methods
module MnoEnterprise
  class BaseResource
    include Her::Model
    include HerExtension::Validations::RemoteUniquenessValidation
    
    include_root_in_json :data
    use_api MnoEnterprise.mnoe_api_v1
    
    # TODO: spec that changed_attributes is empty
    # after a KLASS.all / KLASS.where etc..
    after_find { |res| res.instance_variable_set(:@changed_attributes, {}) }
    
    # Attributes common to all classes
    attributes :id, :created_at, :updated_at
    
    # Class query methods
    class << self
      # Delegate the following methods to `scoped`
      # Clear relation params for each class level query
      [:all, :where, :create, :find, :first_or_create, :first_or_initialize, :limit, :order_by, :sort_by, :order, :sort].each do |method|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{method}(*params)
            scoped.reset_params
            scoped.send(#{method.to_sym.inspect}, *params)
          end
        RUBY
      end
      
      # Emulate ActiveRecord for Her
      def first(n = 1)
        return [] unless n > 0
        q = self.order_by('id.asc').limit(n)
        n == 1 ? q.to_a.first : q.to_a
      end
    
      # Emulate ActiveRecord for Her
      def last(n = 1)
        return [] unless n > 0
        q = self.order_by('id.desc').limit(n)
        n == 1 ? q.to_a.first : q.to_a
      end
      
      # Find first record using a hash of attributes
      def find_by(hash)
        self.where(hash).limit(1).first
      end
    end
    
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
      @attributes.update(self.class.find(self.id).attributes)
      self.run_callbacks :find
      self
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
      #     :attribute => "name"
      #     :value => "can't be blank"
      #   }
      # ]
      def process_response_errors
        if self.response_errors && self.response_errors.any?
          self.response_errors.each do |error|
            key = error[:attribute] && !error[:attribute].empty? ? error[:attribute] : :base
            val = error[:value] && !error[:value].empty? ? error[:value] : error[:title]
            self.errors[key.to_sym] << val
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
