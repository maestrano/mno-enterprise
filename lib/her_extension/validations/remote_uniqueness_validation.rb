# TODO:
# - spec module
# - spec that validator ignores records with the same id
module HerExtension
  module Validations
    
    # Validate the uniqueness of a field by performing a remote API call
    class RemoteUniquenessValidator < ::ActiveModel::EachValidator
      def validate_each(record,attribute,value)
        puts "\n\n\n\nI AM IN REMOTE UNIQUENESS VALIDATOR\n\n\n\n"
        list = record.class.where({ attribute => value }).limit(1)
        
        if list.reject { |e| e.id == record.id }.any?
          error_options = options.except(:case_sensitive, :scope, :conditions)
          error_options[:value] = value
          record.errors.add(attribute, :taken, error_options)
        end
      end
    end
    
    # This module overrides validates_uniqueness_of
    module RemoteUniquenessValidation
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def validates_uniqueness_of(*attr_names)
          validates_with RemoteUniquenessValidator, _merge_attributes(attr_names)
        end
      end
    end
  end
end