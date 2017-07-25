require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::TasksController, type: :routing do
    routes { MnoEnterprise::Engine.routes }
    
    it 'routes to #index' do
      expect(get('/jpi/v1/tasks')).to route_to("mno_enterprise/jpi/v1/tasks#index")
    end
    
    it 'routes to #show' do
      expect(get('/jpi/v1/tasks/1')).to route_to("mno_enterprise/jpi/v1/tasks#show", id:'1')
    end
    
    it 'routes to #create' do
      expect(post('/jpi/v1/tasks')).to route_to("mno_enterprise/jpi/v1/tasks#create")
    end
    
    it 'routes to #update' do
      expect(put('/jpi/v1/tasks/1')).to route_to("mno_enterprise/jpi/v1/tasks#update", id:'1')
    end
  end
end
