module JsonApiClientExtension
  module Validations
    class RemoteUniquenessValidator < ::ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        list = record.class.where({attribute => value}).paginate(page: 1, per_page: 1).to_a

        if list.reject { |e| e.id == record.id }.any?
          error_options = options.except(:case_sensitive, :scope, :conditions)
          error_options[:value] = value
          record.errors.add(attribute, :taken, error_options)
        end
      end
    end
  end
end

