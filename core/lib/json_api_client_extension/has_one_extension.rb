module JsonApiClientExtension::HasOneExtension
  extend ActiveSupport::Concern

  class_methods do
    def has_one(attr_name, options = {})
      class_eval <<-CODE
        def #{attr_name}_id=(id)
          ActiveSupport::Deprecation.warn(self.class.name + ".#{attr_name}_id Use relationships instead")
          association = id ? {data: {type: "#{attr_name.to_s.pluralize}", id: id.to_s}} : nil
          self.relationships.#{attr_name} = association
        end
        def #{attr_name}_id
          # First we try in the relationship
          relationship_definitions = self.relationships.try(:#{attr_name})
          return nil unless relationship_definitions
          relationship_definitions.dig(:data, :id)
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
