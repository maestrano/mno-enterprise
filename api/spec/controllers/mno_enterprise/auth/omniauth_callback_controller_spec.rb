require 'rails_helper'

module MnoEnterprise
  describe Auth::OmniauthCallbacksController, type: :controller do
    routes { MnoEnterprise::Engine.routes }

    ACTIVE_STATUSES = MnoEnterprise::AppInstance::ACTIVE_STATUSES.join(',')


    describe 'provides callbacks for the providers' do
      before do
        Devise.omniauth :facebook, 'key', 'secret', secure_image_url: true
        MnoEnterprise::Auth.send(:remove_const, :OmniauthCallbacksController)
        load 'app/controllers/mno_enterprise/auth/omniauth_callbacks_controller.rb'
      end
      # No described_class as it doesn't take into account the reloading above
      let(:controller) { MnoEnterprise::Auth::OmniauthCallbacksController.new }

      it { expect(controller).to respond_to(:intuit) }
      it { expect(controller).to respond_to(:facebook) }
    end

    describe '.setup_apps' do
      let(:app) { build(:app) }
      let(:app_instance) { build(:app_instance, app: app, oauth_keys_valid: false) }
      let(:user) { build(:user) }
      let(:orga_relation) { build(:orga_relation, :super_admin) }
      let(:organization) { build(:organization) }
      let(:app_nids) { [app.nid] }
      let(:options) { {} }
      let(:get_app_instances_params) { { filter: { 'owner.id': organization.id, 'status.in': ACTIVE_STATUSES } } }

      # setup_apps is a private method
      subject { controller.send(:setup_apps, user, app_nids, options) }

      before do
        stub_api_v2(:get, '/organizations', [organization], [], { filter: { 'users.id': user.id }, fields: { organizations: 'id' } })
        stub_api_v2(:get, '/orga_relations', [orga_relation], [], { filter: { 'user.id': user.id }, fields: { orga_relations: 'role' } })
        stub_api_v2(:get, '/apps', [app], [], { filter: { 'nid.in': app.nid }, fields: { apps: 'id,nid' } })
      end

      context 'when the app_instance already exists' do
        before { stub_api_v2(:get, '/app_instances', [app_instance], [:app], get_app_instances_params) }
        it 'does not create a new app instance' do
          expect(subject.length).to be(1)
          expect(subject.first.id).to eq(app_instance.id)
        end

        describe 'when there is a oauth_keyset' do
          let(:options) { { oauth_keyset: 'oauth_keyset' } }
          let!(:stub) { stub_api_v2(:patch, "/app_instances/#{app_instance.id}", app_instance) }
          it do
            subject
            expect(stub).to have_been_requested
          end
        end

      end
      context 'when there is no previous app instance' do
        let(:provisioned_app_instance) { build(:app_instance) }
        before do
          stub_audit_events
          stub_api_v2(:get, '/app_instances', [], [:app], get_app_instances_params)
          stub_api_v2(:get, '/app_instances/' + provisioned_app_instance.id, provisioned_app_instance, [:owner])
        end
        let!(:stub) { stub_api_v2(:post, '/app_instances/provision', provisioned_app_instance) }
        it 'provisions the app_instance' do
          expect(subject.length).to be(1)
          expect(subject.first.id).to eq(provisioned_app_instance.id)
          expect(stub).to have_been_requested
        end
      end
    end
  end
end
