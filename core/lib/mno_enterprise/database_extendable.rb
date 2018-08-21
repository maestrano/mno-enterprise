require 'active_support/concern'
require 'active_support/core_ext'

# TODO: specs
module MnoEnterprise::DatabaseExtendable
  extend ActiveSupport::Concern

  class_methods do
    def database_extendable(*fields)
      fields.each do |field|
        delegate field.to_sym, "#{field}=".to_sym, to: :extension
      end

      after_save :save_extensions
      after_destroy :delete_extension

      include MnoEnterprise::DatabaseExtendable::InstanceMethods
    end
  end

  module InstanceMethods
    def extension
      @extension ||= klass.where(foreign_key => self.uid).first_or_initialize
    end

    def extension=(extension)
      @extension = extension
    end

    def klass
      "#{self.class}Extension".constantize
    end

    def foreign_key
      self.class.to_s.foreign_key.gsub(/_id/, '_uid')
    end

    protected

    def save_extensions
      # Set extension foreign key
      if extension.send(foreign_key).blank?
        extension.send("#{foreign_key}=", self.uid)
      end
      # Save at all time to 'touch' to  expire the cache
      if extension.changed?
        extension.save
      else
        extension.touch
      end
    end

    def delete_extension
      extension.destroy
    end
  end

end
