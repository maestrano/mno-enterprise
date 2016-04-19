require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::InvitesController do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #create' do
      expect(post('/jpi/v1/admin/organizations/1/users/2/invites')).to route_to('mno_enterprise/jpi/v1/admin/invites#create', organization_id: '1', user_id: '2', format: 'json')
    end
  end
end
