# Allow unconfirmed user to be impersonated
# We override User#confirmation_required? when impersonating
Warden::Manager.prepend_after_set_user do |record, warden, options|
  impersonator_id =  warden.env['rack.session'][:impersonator_user_id]

  if impersonator_id
    class <<record
      # Callback to overwrite if confirmation is required or not.
      def confirmation_required?
        false
      end
    end
  end
end
