module MnoEnterprise
  class Tenant < BaseResource
    def self.show
      self.get('tenant')
    end
  end
end
