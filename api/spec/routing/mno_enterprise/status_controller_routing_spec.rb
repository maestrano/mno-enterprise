require "rails_helper"

module MnoEnterprise
  RSpec.describe StatusController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    it 'routes to #ping' do
      expect(get('/ping')).to route_to('mno_enterprise/status#ping')
    end

    it 'routes to #version' do
      expect(get('/version')).to route_to('mno_enterprise/status#version')
    end

    it 'routes to #health_check' do
      expect(get('/health_check')).to route_to('health_check/health_check#index')
    end
  end
end
