require 'rails_helper'

module MnoEnterprise
  RSpec.describe Devise::RegistrationsController, type: :routing do
    routes { MnoEnterprise::Engine.routes }

    context 'when registration is enabled' do
      before(:all) do
        Settings.dashboard.registration.enabled = true
        Rails.application.reload_routes!
      end

      it 'routes to #new' do
        expect(get('/auth/users/sign_up')).to route_to("mno_enterprise/auth/registrations#new")
      end

      it 'routes to #create' do
        expect(post('/auth/users')).to route_to("mno_enterprise/auth/registrations#create")
      end
    end

    context 'when registration is disabled' do
      before(:all) do
        Settings.dashboard.registration.enabled = false
        Rails.application.reload_routes!
      end

      it 'does not route to #new' do
        expect(get('/auth/users/sign_up')).not_to be_routable
      end

      it 'does not route to #create' do
        expect(post('/auth/users')).not_to be_routable
      end
    end
  end
end

