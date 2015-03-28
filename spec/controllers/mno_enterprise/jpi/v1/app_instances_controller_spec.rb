require 'rails_helper'

describe Jpi::V1::AppsController do
  render_views
  before { request.env["HTTP_ACCEPT"] = 'application/json' }

  describe "index" do
    let(:user) { create(:user) }
    let(:orga) { create(:organization) }
    let(:app_instance) { create(:app_instance, owner: orga) }
    let(:ext_app_instance) { create(:app_instance) }
    
    let(:timestamp) { nil }
    let(:app_ts) { nil }
    
    let(:list) { AppInstance.where(id: [app_instance,ext_app_instance].map(&:id)) }
    let(:org_list) { list.where(owner_type: 'Organization', owner_id: orga.id) }
    
    subject { get :index, organization_id: orga.id, timestamp: timestamp }
    
    it_behaves_like "jpi v1 protected action"
    
    context "signed in" do
      before { orga.add_user(user) }
      before { sign_in user }
      before { allow(AppInstance).to receive(:accessible_by).and_return(list) }
      before { app_instance.update_attribute(:updated_at,app_ts) if app_ts }
      before { subject }
      
      it "is successful" do
        expect(subject).to be_successful
      end
      
      context 'no applications' do
        let!(:app_instance) { create(:app_instance) }
        let(:list) { AppInstance.where("1 = 2") }
        
        it { expect(assigns(:app_instances)).to be_empty }
      end
      
      context 'no timestamp' do
        it { expect(assigns(:app_instances).to_a).to eq(org_list.to_a) }
        
        describe 'and terminated app_instances' do
          let(:app_instance) { create(:app_instance, status: 'terminated') }
          it { expect(assigns(:app_instances)).to be_empty }
        end
      end
      
      context 'with timestamp' do
        let(:timestamp) { Time.now.to_i }
        let(:app_ts) { 3.minutes.ago }
        
        context 'and app_instances updated before' do
          it { expect(assigns(:app_instances)).to be_empty }
        end
        
        context 'and app_instances updated after' do
          let(:app_ts) { 3.minutes.from_now }
          it { expect(assigns(:app_instances).to_a).to eq(org_list) }

          it 'returns the apps representation' do
            expect(JSON.parse(response.body)["app_instances"].keys).to include("app_instance_#{app_instance.id}")
          end
        end
      end
    end
  end

  describe "#index" do
    let(:user) { create(:user) }
    let(:organization) { create(:organization) }

    before { organization.add_user(user) }
    before { sign_in user }

    context "app instance is a connector" do
      let(:oauth_keys) { {token: 'foo', secret: 'bar', expires: 10.minutes.from_now.utc, company_name: organization.name, version: 'connector 2.0' } }
      let!(:app_instance) { create(:connector_app_instance, owner: organization, oauth_keys: oauth_keys, updated_at: Time.now) }

      subject! { get :index, organization_id: organization.id, timestamp: 1.minutes.ago }

      it "includes the company name and version in the app_instance representation" do
        expect(JSON.parse(response.body)["app_instances"]["app_instance_#{app_instance.id}"]).to include({
          "oauthCompanyName"=>organization.name,
          "connectorVersion"=>'connector 2.0'
        })
      end
    end
  end

end
