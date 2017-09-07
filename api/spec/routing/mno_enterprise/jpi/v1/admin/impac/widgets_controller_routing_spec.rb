require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::Impac::WidgetsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #create' do
      expect(post('/jpi/v1/admin/impac/dashboard_templates/1/widgets')).to route_to('mno_enterprise/jpi/v1/admin/impac/widgets#create', dashboard_template_id: '1', format: 'json')
    end

    it 'routes to #update' do
      expect(put('/jpi/v1/admin/impac/widgets/2')).to route_to('mno_enterprise/jpi/v1/admin/impac/widgets#update', id: '2', format: 'json')
      expect(patch('/jpi/v1/admin/impac/widgets/2')).to route_to('mno_enterprise/jpi/v1/admin/impac/widgets#update', id: '2', format: 'json')
    end

    it 'routes to #destroy' do
      expect(delete('/jpi/v1/admin/impac/widgets/2')).to route_to('mno_enterprise/jpi/v1/admin/impac/widgets#destroy', id: '2', format: 'json')
    end
  end
end
