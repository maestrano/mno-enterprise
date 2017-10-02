require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::CloudAppsController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin

    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    # Stub model calls
    let(:user) { build(:user, :admin) }
    let(:app) { build(:app, stack: 'cloud', uid: 'cld-1234', name: 'My App', api_key: '28034234') }

    before do
      stub_user(user)
      stub_api_v2(:get, "/apps/#{app.id}", app)
      stub_api_v2(:patch, "/apps/#{app.id}", app)
      sign_in user
    end

    context 'admin user' do
      describe '#index' do
        subject { get :index }
        let!(:stub) { stub_api_v2(:get, "/apps", [app], [], { filter: { stack: 'cloud' } }) }
        it_behaves_like 'a jpi v1 admin action'
        it 'returns the cloud aplications' do
          subject
          expect(JSON.parse(response.body)).to eq({ "cloud_apps" => [{ "id" => app.id, "uid" => app.uid, "name" => app.name, "api_key" => app.api_key, "tiny_description" => app.tiny_description, "description" => app.description, "metadata_url" => nil, "details" => nil, "terms_url" => app.terms_url }] })
        end
        it 'does the request' do
          subject
          expect(stub).to have_been_requested
        end
      end

      describe '#update' do
        let(:params) { { name: 'CloudApp', terms_url: 'terms.com' } }
        before { stub_api_v2(:get, "/apps/#{app.id}", app) }
        let!(:stub) { stub_api_v2(:patch, "/apps/#{app.id}", app) }
        subject { put :update, id: app.id, cloud_app: params }
        it_behaves_like 'a jpi v1 admin action'
        it do
          subject
          expect(stub).to have_been_requested
          expect(response).to be_success
        end
      end

      describe '#regenerate_api_key' do
        subject { put :regenerate_api_key, id: app.id }
        let!(:stub) { stub_api_v2(:patch, "/apps/#{app.id}/regenerate_api_key", app) }
        it_behaves_like 'a jpi v1 admin action'
        it do
          subject
          expect(stub).to have_been_requested
          expect(response).to be_success
        end
      end
    end
  end
end
