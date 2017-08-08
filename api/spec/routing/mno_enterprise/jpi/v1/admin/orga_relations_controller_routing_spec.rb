require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::OrgaRelationsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }
    
    it 'routes to #index' do
      expect(get('/jpi/v1/admin/orga_relations')).to route_to("mno_enterprise/jpi/v1/admin/orga_relations#index", format: "json")
    end
    
    it 'routes to #show' do
      expect(get('/jpi/v1/admin/orga_relations/1')).to route_to("mno_enterprise/jpi/v1/admin/orga_relations#show", format: "json", id:'1')
    end
  end
end
