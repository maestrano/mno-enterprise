require 'devise/hooks/password_expirable'

module Devise
  module Models
    module PasswordExpirable
      extend ActiveSupport::Concern

      # is an password change required?
      def need_change_password?
        if self.expire_password_after.is_a? Fixnum or self.expire_password_after.is_a? Float
          self.password_changed_at.nil? or self.password_changed_at < self.expire_password_after.ago
        else
          false
        end
      end

      def expire_password_after
        self.class.expire_password_after
      end

      private

      module ClassMethods
        Devise::Models.config(self, :expire_password_after)
      end
    end
  end
end
