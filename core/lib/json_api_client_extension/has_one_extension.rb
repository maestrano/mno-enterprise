module JsonApiClientExtension::HasOneExtension
  extend ActiveSupport::Concern

  class_methods do
    def has_one(attr_name, options = {})
      class_eval <<-CODE
        def #{attr_name}_id=(id)
          # Uncomment when doing refactoring
          # ActiveSupport::Deprecation.warn(self.class.name + ".#{attr_name}_id= Use relationships instead")
          super
        end
        def #{attr_name}_id
          # Uncomment when doing refactoringgit 
          # ActiveSupport::Deprecation.warn(self.class.name + ".#{attr_name}_id Use relationships instead")
          super
        end
        def #{attr_name}=(relation)
          self.relationships.#{attr_name} = relation
          relations[:#{attr_name}] = relation
        end
        def #{attr_name}
          relations[:#{attr_name}] ||= super
        end

      CODE
      super
    end
  end
end
