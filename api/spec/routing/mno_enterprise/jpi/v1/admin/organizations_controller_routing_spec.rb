require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::OrganizationsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #index' do
      expect(get('/jpi/v1/admin/organizations')).to route_to('mno_enterprise/jpi/v1/admin/organizations#index', format: 'json')
    end

    it 'routes to #show' do
      expect(get('/jpi/v1/admin/organizations/1')).to route_to('mno_enterprise/jpi/v1/admin/organizations#show', format: 'json', id: '1')
    end

    it 'routes to #in_arrears' do
      expect(get('/jpi/v1/admin/organizations/in_arrears')).to route_to('mno_enterprise/jpi/v1/admin/organizations#in_arrears', format: 'json')
    end

    it 'routes to #count' do
      expect(get('/jpi/v1/admin/organizations/count')).to route_to('mno_enterprise/jpi/v1/admin/organizations#count', format: 'json')
    end

    it 'routes to #create' do
      expect(post('/jpi/v1/admin/organizations')).to route_to('mno_enterprise/jpi/v1/admin/organizations#create', format: 'json')
    end

    it 'routes to #invite_member' do
      expect(post('/jpi/v1/admin/organizations/1/users')).to route_to('mno_enterprise/jpi/v1/admin/organizations#invite_member', id: '1', format: 'json')
    end

    it 'routes to #freeze' do
      expect(put('/jpi/v1/admin/organizations/1/freeze')).to route_to("mno_enterprise/jpi/v1/admin/organizations#freeze_account", id: '1', format: 'json')
    end

    it 'routes to #unfreeze' do
      expect(put('/jpi/v1/admin/organizations/1/unfreeze')).to route_to("mno_enterprise/jpi/v1/admin/organizations#unfreeze", id: '1', format: 'json')
    end

    it 'routes to #download_batch_example' do
      expect(get('/jpi/v1/admin/organizations/download_batch_example')).to route_to('mno_enterprise/jpi/v1/admin/organizations#download_batch_example', format: 'json')
    end

    it 'routes to #batch_import' do
      expect(post('/jpi/v1/admin/organizations/batch_import')).to route_to('mno_enterprise/jpi/v1/admin/organizations#batch_import', format: 'json')
    end
  end
end
