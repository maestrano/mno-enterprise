require 'openssl'

module MnoEnterprise::Concerns::Models::IntercomUser
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    if MnoEnterprise.intercom_enabled?
      # Return intercom user hash
      # This is used in secure mode
      def intercom_user_hash
        OpenSSL::HMAC.hexdigest('sha256', MnoEnterprise.intercom_api_secret, (self.id || self.email).to_s)
      end
    end
  end

  #==================================================================
  # Class methods
  #==================================================================
  module ClassMethods
    # def some_class_method
    #   'some text'
    # end
  end

  #==================================================================
  # Instance methods
  #==================================================================
end