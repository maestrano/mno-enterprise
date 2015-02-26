module MnoEnterprise
  class BaseResource < ActiveResource::Base
    # General connection Details
    self.site = "#{URI.join(MnoEnterprise.mno_api_host,MnoEnterprise.mno_api_root_path)}"
    self.user = MnoEnterprise.tenant_id
    self.password = MnoEnterprise.tenant_key
  end
end
