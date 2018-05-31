require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::AccountTransactionsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #create' do
      expect(post('/jpi/v1/admin/account_transactions')).to route_to('mno_enterprise/jpi/v1/admin/account_transactions#create', format: 'json')
    end
  end
end
