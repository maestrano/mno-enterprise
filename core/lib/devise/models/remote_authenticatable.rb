module Devise
  module Models
    module RemoteAuthenticatable
      extend ActiveSupport::Concern

      #
      # Here you do the request to the external webservice
      #
      # If the authentication is successful you should return
      # a resource instance
      #
      # If the authentication fails you should return false
      #
      def remote_authentication(authentication_hash)
        self.class.authenticate(authentication_hash) # call MnoEnterprise::User.authenticate
      end

      included do
        before_update :track_password_changed
        after_update :send_password_change_notification, if: :send_password_change_notification?
      end

      def send_password_change_notification
        send_devise_notification(:password_change)
      end

      ####################################
      # Overriden methods from Devise::Models::Authenticatable
      ####################################
      module ClassMethods
        # Flag to enable password change notification
        Devise::Models.config(self, :send_password_change_notification)

        # This method is called from:
        # Warden::SessionSerializer in devise
        #
        # It takes as many params as elements had the array
        # returned in serialize_into_session
        #
        # Recreates a resource from session data
        def serialize_from_session(key,salt)
          record = Rails.cache.fetch(['user', key], expires_in: 1.minutes) do
            to_adapter.get(key)
          end.tap {|r| r && r.clear_association_cache}
          record if record && record.authenticatable_salt == salt
        end

        # Here you have to return and array with the data of your resource
        # that you want to serialize into the session
        #
        # You might want to include some authentication data
        def serialize_into_session(record)
          [record.to_key, record.authenticatable_salt]
        end

      end

      protected

        # We want to send the notification once the password has changed but
        # we won't have access to dirty attributes.
        # Flag change before the model is saved.
        # Do not send a notification at confirmation
        def track_password_changed
          @password_changed = password_changed? && confirmed_at_was.present?
          true # before callback needs to return true to continue
        end

        def send_password_change_notification?
          self.class.send_password_change_notification && @password_changed
        end
    end
  end
end
