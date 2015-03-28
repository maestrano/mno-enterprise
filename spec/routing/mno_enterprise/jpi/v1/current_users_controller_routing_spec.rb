require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::CurrentUsersController, type: :routing do
    routes { MnoEnterprise::Engine.routes }
    it 'routes to #show' do
      expect(get('/jpi/v1/current_user')).to route_to("mno_enterprise/jpi/v1/current_users#show")
    end
  end
end

