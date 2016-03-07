require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::CloudAppsController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    # Stub model calls
    let(:admin) { build(:user, :admin) }
    let(:app) { build(:app, stack: 'cloud', uid: 'cld-1234', name: 'My App', api_key: '28034234') }

    before do
      api_stub_for(get: "/users/#{admin.id}", response: from_api(admin))
      api_stub_for(get: "/apps", response: from_api([app]))
      api_stub_for(get: "/apps/#{app.id}", response: from_api(app))
      api_stub_for(put: "/apps/#{app.id}", response: from_api(app))
      api_stub_for(put: "/users/#{admin.id}", response: from_api(admin))
    end

    context "admin user" do
      before do
        sign_in admin
      end

      describe "#index" do
        subject { get :index }
        
        it 'returns the cloud aplications' do
          subject
          expect(JSON.parse(response.body)).to eq({"cloud_apps"=>[{"id"=>app.id, "uid"=>app.uid, "name"=>app.name, "api_key"=>app.api_key, "tiny_description"=>app.tiny_description, "description"=>app.description, "metadata_url"=>nil, "details"=>nil, "terms_url"=>app.terms_url}]})
        end
      end

      describe '#update' do
        let(:params) { {name: 'CloudApp', terms_url: 'terms.com'} }
        subject { put :update, id: app.id, cloud_app: params }

        before { allow(MnoEnterprise::App).to receive(:find) { app } }

        it 'assigns the cloud app' do
          subject
          expect(assigns[:cloud_app]).to eq(app)
        end

        it 'updates the cloud app' do
          expect(app).to receive(:save) { true }
          subject
          expect(app.terms_url).to eq(params[:terms_url])
        end

        it 'only updates authorized fields' do
          subject
          expect(app.name).to eq('My App')
        end

        it 'is successful' do
          subject
          expect(response).to be_success
        end
      end

      describe "#regenerate_api_key" do
        subject { put :regenerate_api_key, id: app.id }
        
        it 'regenerates the API key' do
          expect_any_instance_of(MnoEnterprise::App).to receive(:regenerate_api_key!)
          subject
        end
      end

      describe "#refresh_metadata" do
        subject { put :refresh_metadata, id: app.id, metadata_url: 'http://test.com' }
        
        context 'with a valid response' do
          it 'refreshes the metadata' do
            expect(subject).to render_template(:show)
          end
        end

        context 'with an error response' do
          before { expect_any_instance_of(MnoEnterprise::App).to receive(:refresh_metadata!).and_return({errors: [{detail: 'error'}]}) }

          it 'returns the error message' do
            subject
            expect(JSON.parse(response.body)).to eq({"errors" => [{"detail"=>"error"}]})
          end
        end
      end
    end
  end

end
