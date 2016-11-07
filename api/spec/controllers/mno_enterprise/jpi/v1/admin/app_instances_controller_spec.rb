require 'rails_helper'

# TODO: spec AppInstance response
module MnoEnterprise
  describe Jpi::V1::Admin::AppInstancesController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    let(:user) { build(:user, :admin, :with_organizations) }
    before do
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      sign_in user
    end

    shared_examples "jpi v1 admin action" do
      context 'with guest user' do
        it "prevents access" do
          sign_out user
          expect(subject).to_not be_successful
          expect(subject.code).to eq('401')
        end
      end

      context 'with signed in user not admin' do
        it "authorizes access" do
          sign_in user
          expect(subject).to_not be_successful
          expect(subject.code).to eq('403')
        end
      end

      context 'with signed in admin' do
        it "authorizes access" do
          sign_in user
          expect(subject).to be_successful
        end
      end
    end

    describe 'DELETE #destroy' do

      # Stub AppInstance
      let(:app_instance) { build(:app_instance) }
      before { api_stub_for(get: "/app_instances/#{app_instance.id}", respond_with: app_instance)}
      before { api_stub_for(delete: "/app_instances/#{app_instance.id}", response: ->{ app_instance.status = 'terminated'; from_api(app_instance) }) }

      subject { delete :destroy, id: app_instance.id }

      # it_behaves_like "jpi v1 admin action"
      # If admin_role present=> ok if not => 401/403

      it_behaves_like "jpi v1 admin action"

      context 'when user is not admin' do
        let(:user) { build(:user, :with_organizations) }
        before do
          api_stub_for(get: "/users/#{user.id}", response: from_api(user))
          sign_in user
        end

        it '401/403'
      end

      context 'when user is an admin' do
        it 'success'
      end

      it { subject; expect(app_instance.status).to eq('terminated') }
    end
  end
end
