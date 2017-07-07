# MonkeyPatching json_api_client, see: https://github.com/chingor13/json_api_client/pull/263
module JsonApiClientExtension::ResourceExtension
  extend ActiveSupport::Concern

  included do
    def initialize(params = {})
      @persisted = nil
      self.links = self.class.linker.new(params.delete("links") || {})
      self.relationships = self.class.relationship_linker.new(self.class, params.delete("relationships") || {})
      self.attributes = params.merge(self.class.default_attributes)

      self.class.schema.each_property do |property|
        attributes[property.name] = property.default unless attributes.has_key?(property.name) || property.default.nil?
      end

      self.class.associations.each do |association|
        if params.has_key?(association.attr_name.to_s)
          set_attribute(association.attr_name, params[association.attr_name.to_s])
        end
      end
    end
  end
end
