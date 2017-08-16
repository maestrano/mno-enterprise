require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::TenantsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #show' do
      expect(get('/jpi/v1/admin/tenant')).to route_to("mno_enterprise/jpi/v1/admin/tenants#show", format: "json")
    end

    it 'routes to #update' do
      expect(patch('/jpi/v1/admin/tenant')).to route_to("mno_enterprise/jpi/v1/admin/tenants#update", format: "json")
    end

    it 'routes to #update_domain' do
      expect(patch('/jpi/v1/admin/tenant/domain')).to route_to("mno_enterprise/jpi/v1/admin/tenants#update_domain", format: "json")
      expect(put('/jpi/v1/admin/tenant/domain')).to route_to("mno_enterprise/jpi/v1/admin/tenants#update_domain", format: "json")
    end

    it 'routes to #add_certificates' do
      expect(post('/jpi/v1/admin/tenant/ssl_certificates')).to route_to("mno_enterprise/jpi/v1/admin/tenants#add_certificates", format: "json")
    end
  end
end

