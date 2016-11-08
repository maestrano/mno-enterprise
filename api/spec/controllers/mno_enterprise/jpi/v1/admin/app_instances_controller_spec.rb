require 'rails_helper'

# TODO: spec AppInstance response
module MnoEnterprise
  include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

  describe Jpi::V1::Admin::AppInstancesController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    let(:user) { build(:user, :admin, :with_organizations) }
    before do
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      sign_in user
    end

    describe 'DELETE #destroy' do
      # Stub AppInstance
      let(:app_instance) { build(:app_instance) }
      before { api_stub_for(get: "/app_instances/#{app_instance.id}", respond_with: app_instance)}
      before { api_stub_for(delete: "/app_instances/#{app_instance.id}", response: ->{ app_instance.status = 'terminated'; from_api(app_instance) }) }

      subject { delete :destroy, id: app_instance.id }

      it_behaves_like "a jpi v1 admin action"

      it { subject; expect(app_instance.status).to eq('terminated') }
    end
  end
end
