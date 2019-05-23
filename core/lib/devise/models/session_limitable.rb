require 'devise/hooks/session_limitable'

module Devise
  module Models
    # SessionLimited ensures, that there is only one session usable per account at once.
    # If someone logs in, and some other is logging in with the same credentials,
    # the session from the first one is invalidated and not usable anymore.
    # The first one is redirected to the sign page with a message, telling that 
    # someone used his credentials to sign in.
    module SessionLimitable
      extend ActiveSupport::Concern

      def update_unique_session_id!(unique_session_id)
        self.attributes = {
          unique_session_id: unique_session_id
        }
        save!
        reload
      end
    end
  end
end
