require 'rails_helper'

def mnoe_home_path
  controller.send(:mnoe_home_path)
end

module MnoEnterprise
  describe ProvisionController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }

    # Create user and organization + mutual associations
    let(:user) { build(:user, :admin, :with_organizations) }
    let(:organization) { user.organizations.first }
    let!(:ability) { stub_ability }
    let(:organizations) { [organization] }

    before { stub_audit_events }

    before do
      stub_user(user)
      allow_any_instance_of(MnoEnterprise::User).to receive(:organizations).and_return(organizations)
    end

    describe 'GET #new' do
      let(:params_org_id) { organization.id }

      let(:params) { {apps: ['vtiger'], organization_id: params_org_id} }
      subject { get :new, params }

      describe 'guest' do
        before { subject }
        it { expect(response).to redirect_to(new_user_registration_path) }
      end

      context 'signed in' do
        let(:authorized) { true }
        before do
          sign_in user
          allow(ability).to receive(:cannot?).with(:manage_app_instances, organization).and_return(!authorized)
          subject
        end

        context 'without organization_id' do
          let(:params_org_id) { nil }

          context 'with multiple organizations available' do
            let(:organizations) { [organization, organization] }
            it { expect(response).to render_template('mno_enterprise/provision/_select_organization') }
          end

          context 'with one organization available' do
            let(:organizations) { [organization] }

            it { expect(response).to render_template('mno_enterprise/provision/_provision_apps') }
            it { expect(assigns[:organization]).to eq(organization) }

            describe "unauthorized" do
              let(:authorized) { false }

              let(:error_fragment) { "#!?#{URI.encode_www_form([['flash', {msg: "Unfortunately you do not have permission to purchase products for this organization", type: :error}.to_json]])}" }

              it 'redirect to the dashboard with an error message' do
                expect(response).to redirect_to(mnoe_home_path + error_fragment)
              end
            end
          end
        end

        context 'with organization_id' do
          let(:organizations) { [organization, organization] }

          context 'authorized' do
            it { expect(response).to render_template('mno_enterprise/provision/_provision_apps') }
          end

          context 'unauthorized' do
            let(:authorized) { false }
            context 'with multiple organizations available' do
              let(:organizations) { [organization, organization] }

              it 'display an errors message and display the list of organization' do
                subject
                expect(controller).to set_flash.now[:alert] #.to('Unfortunately you do not have permission to purchase products for this organization')
                expect(response).to be_success
              end

              it { expect(response).to render_template('mno_enterprise/provision/_select_organization') }
            end

            context 'with one organization available' do
              let(:organizations) { [organization] }
              let(:error_fragment) { "#!?#{URI.encode_www_form([['flash', {msg: "Unfortunately you do not have permission to purchase products for this organization", type: :error}.to_json]])}" }

              it 'redirect to the dashboard with an error message' do
                expect(response).to redirect_to(mnoe_home_path + error_fragment)
              end
            end
          end
        end

      end
    end

    describe 'POST #create' do
      let(:params_org_id) { organization.id }
      let(:app_instance) { build(:app_instance) }
      let(:params) { {apps: ['vtiger'], organization_id: params_org_id} }
      subject { post :create, params }
      before do
        stub_api_v2(:post, "/app_instances/provision", app_instance)
        stub_api_v2(:get, "/app_instances/#{app_instance.id}", app_instance, [:owner])
      end

      describe 'guest' do
        before { subject }
        it { expect(response).to_not be_success }
      end

      describe 'signed in' do
        let(:authorized) { true }
        before do
          sign_in user
          allow(ability).to receive(:can?).with(any_args).and_return(authorized)
          subject
        end

        it { expect(response).to be_success }

        it('audits the event') { assert_requested_audit_event }

        it 'deletes the previous url from session to avoid double provisioning' do
          subject
          expect(session[:previous_url]).to be_nil
        end
      end
    end

  end
end
