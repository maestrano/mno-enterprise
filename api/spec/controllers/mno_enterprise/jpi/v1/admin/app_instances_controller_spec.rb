require 'rails_helper'

# TODO: spec AppInstance response
module MnoEnterprise
  describe Jpi::V1::Admin::AppInstancesController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }
    before { stub_audit_events }

    let(:user) { build(:user, :admin) }
    let(:organization) { build(:organization) }
    let!(:current_user_stub) { stub_user(user) }

    before do
      sign_in user
    end

    describe 'DELETE #destroy' do
      # Stub AppInstance
      let(:app_instance) { build(:app_instance, owner: organization) }

      before { stub_api_v2(:get, "/app_instances/#{app_instance.id}", app_instance, [:owner]) }
      let!(:stub) { stub_api_v2(:delete, "/app_instances/#{app_instance.id}/terminate") }

      subject { delete :destroy, id: app_instance.id }

      it_behaves_like 'a jpi v1 admin action'

      context 'success' do
        before { subject }
        it { expect(response).to be_success }
        it { expect(stub).to have_been_requested }
      end
    end
  end
end
