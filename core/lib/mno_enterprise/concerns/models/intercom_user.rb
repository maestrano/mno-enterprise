require 'openssl'

module MnoEnterprise::Concerns::Models::IntercomUser
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
  end

  #==================================================================
  # Class methods
  #==================================================================
  module ClassMethods
  end

  #==================================================================
  # Instance methods
  #==================================================================
  # Return intercom user hash
  # This is used in secure mode
  def intercom_user_hash
    OpenSSL::HMAC.hexdigest('sha256', MnoEnterprise.intercom_api_secret, (self.id || self.email).to_s) if MnoEnterprise.intercom_api_secret
  end

  # Return Intercom user data hash
  def intercom_data(update_last_request_at = true)
    data = {
      user_id: self.id,
      name: [self.name, self.surname].join(' '),
      email: self.email,
      created_at: self.created_at.to_i,
      last_seen_ip: self.last_sign_in_ip,
      custom_attributes: {
        first_name: self.name,
        surname: self.surname,
        confirmed_at: self.confirmed_at,
      },
      update_last_request_at: update_last_request_at
    }
    data[:custom_attributes][:phone]= self.phone if self.phone
    data[:custom_attributes][:external_id]= self.external_id if self.external_id

    data
  end
end
