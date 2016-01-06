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
      [:all, :where, :create, :find, :first_or_create, :first_or_initialize, :limit, :skip, :order_by, :sort_by, :order, :sort].each do |method|
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{method}(*params)
            Her::Model::Relation.new(self).send(#{method.to_sym.inspect}, *params)
          end
        RUBY
      end

      # ActiveRecord Compatibility for Her
      def first(n = 1)
        return [] unless n > 0
        q = self.order_by('id.asc').limit(n)
        n == 1 ? q.to_a.first : q.to_a
      end

      # ActiveRecord Compatibility for Her
      def last(n = 1)
        return [] unless n > 0
        q = self.order_by('id.desc').limit(n)
        n == 1 ? q.to_a.first : q.to_a
      end

      # Find first record using a hash of attributes
      def find_by(hash)
        self.where(hash).limit(1).first
      end

      # ActiveRecord Compatibility for Her
      # Returns the class descending directly from MnoEnterprise::BaseResource, or
      # an abstract class, if any, in the inheritance hierarchy.
      #
      # If A extends MnoEnterprise::BaseResource, A.base_class will return A. If B descends from A
      # through some arbitrarily deep hierarchy, B.base_class will return A.
      #
      # If B < A and C < B and if A is an abstract_class then both B.base_class
      # and C.base_class would return B as the answer since A is an abstract_class.
      def base_class
        unless self < BaseResource
          raise Error, "#{name} doesn't belong in a hierarchy descending from BaseResource"
        end

        if superclass == BaseResource || superclass.abstract_class?
          self
        else
          superclass.base_class
        end
      end
    end

    #======================================================================
    # Instance methods
    #======================================================================
    # Simple cache_key
    # TODO: use the timestamp for better expiration
    def cache_key()
      "#{model_name.cache_key}/#{id}"
    end

    # ActiveRecord Compatibility for Her
    def read_attribute(attr_name)
      get_attribute(attr_name)
    end

    # ActiveRecord Compatibility for Her
    def write_attribute(attr_name, value)
      assign_attributes(attr_name => value)
    end
    alias []= write_attribute

    # ActiveRecord Compatibility for Her
    def save(options={})
      if perform_validations(options)
        ret = super()
        process_response_errors
        ret
      else
        false
      end
    end

    # ActiveRecord Compatibility for Her
    def save!(options={})
      if perform_validations(options)
        ret = super()
        process_response_errors
        raise_record_invalid
      else
        false
      end
    end

    # ActiveRecord Compatibility for Her
    def reload(options = nil)
      @attributes.update(self.class.find(self.id).attributes)
      self.run_callbacks :find
      self
    end

    # ActiveRecord Compatibility for Her
    def update(attributes)
      assign_attributes(attributes)
      save
    end

    # Reset the ActiveModel hash containing all attribute changes
    # Useful when initializing a existing resource using a hash fetched
    # via http call (e.g.: MnoEnterprise::User.authenticate)
    def clear_attribute_changes!
      self.instance_variable_set(:@changed_attributes, {})
    end

    # Returns true if +comparison_object+ is the same exact object, or +comparison_object+
    # is of the same type and +self+ has an ID and it is equal to +comparison_object.id+.
    #
    # Note that new records are different from any other record by definition, unless the
    # other record is the receiver itself. Besides, if you fetch existing records with
    # +select+ and leave the ID out, you're on your own, this predicate will return false.
    #
    # Note also that destroying a record preserves its ID in the model instance, so deleted
    # models are still comparable.
    def ==(comparison_object)
      super ||
        comparison_object.instance_of?(self.class) &&
        !id.nil? &&
        comparison_object.id == id
    end
    alias :eql? :==

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

      # ActiveRecord Compatibility for Her
      def raise_record_invalid
        raise(Her::Errors::ResourceInvalid.new(self))
      end

      # ActiveRecord Compatibility for Her
      def perform_validations(options={}) # :nodoc:
        # errors.blank? to avoid the unexpected case when errors is nil...
        # -> THIS IS A TEMPORARY UGLY FIX
        options[:validate] == false || self.errors.nil? || valid?(options[:context])
      end

  end
end
