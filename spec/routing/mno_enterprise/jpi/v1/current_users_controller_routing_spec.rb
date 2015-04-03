require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::CurrentUsersController, type: :routing do
    routes { MnoEnterprise::Engine.routes }
    
    it 'routes to #show' do
      expect(get('/jpi/v1/current_user')).to route_to("mno_enterprise/jpi/v1/current_users#show")
    end
    
    it 'routes to #update' do
      expect(put('/jpi/v1/current_user')).to route_to("mno_enterprise/jpi/v1/current_users#update")
    end
    
    it 'routes to #create_deletion_request' do
      expect(post('/jpi/v1/current_user/deletion_request')).to route_to("mno_enterprise/jpi/v1/current_users#create_deletion_request")
    end
    
    it 'routes to #cancel_deletion_request' do
      expect(delete('/jpi/v1/current_user/deletion_request')).to route_to("mno_enterprise/jpi/v1/current_users#cancel_deletion_request")
    end
  end
end

