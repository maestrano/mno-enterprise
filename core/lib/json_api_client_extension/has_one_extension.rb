module JsonApiClientExtension::HasOneExtension
  extend ActiveSupport::Concern

  class_methods do
    def has_one(attr_name, options = {})
      setter_log_warning = (Rails.env.test? || Rails.env.development?) ?  "ActiveSupport::Deprecation.warn('#{self.name}.#{attr_name}_id= Use relationships instead')" : ''
      getter_log_warning = (Rails.env.test? || Rails.env.development?) ?  "ActiveSupport::Deprecation.warn('#{self.name}.#{attr_name}_id Use relationships instead')" : ''
      class_eval <<-CODE
        def #{attr_name}_id=(id)
          #{setter_log_warning}
          super
        end
        def #{attr_name}_id
          #{getter_log_warning}
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
