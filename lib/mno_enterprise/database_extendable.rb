require 'active_support/concern'
require 'active_support/core_ext'

module MnoEnterprise::DatabaseExtendable
  extend ActiveSupport::Concern

  class_methods do
    def database_extendable(*fields)
      fields.each do |field|
        delegate field.to_sym, "#{field}=".to_sym, to: :extension
      end

      after_save :save_extensions

      include MnoEnterprise::DatabaseExtendable::InstanceMethods
    end
  end

  module InstanceMethods
    def extension
      @extension ||= klass.where(foreign_key => self.uid).first_or_create
    end

    def klass
      "#{self.class}Extension".constantize
    end

    def foreign_key
      self.class.to_s.foreign_key.gsub(/_id/, '_uid')
    end

    protected

    def save_extensions
      extension.save if extension.changed?
    end
  end

end
