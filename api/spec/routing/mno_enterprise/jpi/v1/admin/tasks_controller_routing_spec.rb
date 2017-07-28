require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::TasksController, type: :routing do
    routes { MnoEnterprise::Engine.routes }
    
    it 'routes to #index' do
      expect(get('/jpi/v1/admin/tasks')).to route_to("mno_enterprise/jpi/v1/admin/tasks#index", format: "json")
    end
    
    it 'routes to #show' do
      expect(get('/jpi/v1/admin/tasks/1')).to route_to("mno_enterprise/jpi/v1/admin/tasks#show", format: "json", id:'1')
    end
    
    it 'routes to #create' do
      expect(post('/jpi/v1/admin/tasks')).to route_to("mno_enterprise/jpi/v1/admin/tasks#create", format: "json")
    end
    
    it 'routes to #update' do
      expect(put('/jpi/v1/admin/tasks/1')).to route_to("mno_enterprise/jpi/v1/admin/tasks#update",  format: 'json', id:'1')
    end
  end
end
