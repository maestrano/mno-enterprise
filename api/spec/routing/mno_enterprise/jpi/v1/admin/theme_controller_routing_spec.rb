require 'rails_helper'

module MnoEnterprise
  RSpec.describe Jpi::V1::Admin::ThemeController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #save' do
      expect(post('/jpi/v1/admin/theme/save')).to route_to('mno_enterprise/jpi/v1/admin/theme#save', format: "json")
    end

    it 'routes to #logo' do
      expect(put('/jpi/v1/admin/theme/logo')).to route_to('mno_enterprise/jpi/v1/admin/theme#logo', format: "json")
    end
  end
end
