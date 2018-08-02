module MnoEnterprise::TestingSupport::SharedExamples::JpiV2ApiController
  RSpec.shared_examples MnoEnterprise::Jpi::V2::ApiController do
    routes { MnoEnterprise::Engine.routes }

    let(:endpoint) { described_class.to_s.demodulize.sub('Controller', '').underscore }
    let(:resource_name) { endpoint.singularize }
    let(:resource_klass) { nil }

    let(:user) { build(:user) }

    # Format the JSON API data Hash for a delete request
    def destroy_attributes(record, resource_name, _)
      {
        id: record.id,
        type: resource_name.pluralize
      }
    end

    # TODO
    def create_attributes(resource_name, resource_klass)
      {}
    end

    # TODO
    def update_attributes(record, resource_name, resource_klass)
      {}
    end

    before do
      # JSONAPI::MEDIA_TYPE
      request.env['HTTP_ACCEPT'] = 'application/vnd.api+json'
      request.env['CONTENT_TYPE'] = 'application/vnd.api+json'
    end

    # Stub MnoHub request
    # TODO: use before all instead of let to speed things up?
    let(:base_url) { URI.join(MnoEnterprise.api_host, MnoEnterprise.mno_api_v2_root_path).to_s }
    let(:basic_auth) { ActionController::HttpAuthentication::Basic.encode_credentials(user.sso_session, '') }
    let(:headers) do
      {
        'Accept' => 'application/vnd.api+json',
        'Content-Type' => 'application/vnd.api+json',
        'Authorization' => basic_auth
      }
    end

    # TODO: Test error handling (error from MnoHub)
    # TODO: Test pagination
    describe 'CRUD actions' do
      # TODO: dynamic
      let(:record) { MnoEnterprise::User.new(id: '1') }

      before do
        stub
        stub_user(user)
        sign_in(user)
        subject
      end

      describe 'GET #index' do
        subject { get :index }

        let(:stub) do
          stub_request(:get, File.join(base_url, endpoint))
            .with(headers: headers)
            .to_return(status: 200, body: '', headers: {})
        end

        it { is_expected.to have_http_status(:ok) }
        it { expect(stub).to have_been_requested }
      end

      describe 'GET #show' do
        subject { get :show, id: record.id }

        let(:stub) do
          stub_request(:get, File.join(base_url, endpoint, record.id))
            .with(headers: headers)
            .to_return(status: 200, body: '', headers: {})
        end

        it { is_expected.to have_http_status(:ok) }
        it { expect(stub).to have_been_requested }
      end

      describe 'POST #create' do
        let(:data) { create_attributes(resource_name, resource_klass) }
        subject { post :create, params: { data: data } }

        let(:stub) do
          # TODO: check body?
          stub_request(:post, File.join(base_url, endpoint))
            .with(headers: headers)
            .to_return(status: 201, body: '', headers: {})
        end

        it { is_expected.to have_http_status(:created) }
        it { expect(stub).to have_been_requested }
      end

      describe 'PATCH #update' do
        let(:data) { update_attributes(record, resource_name, resource_klass) }
        subject { patch :update, id: record.id, data: data }

        let(:stub) do
          # TODO: check body?
          stub_request(:patch, File.join(base_url, endpoint, record.id))
            .with(headers: headers)
            .to_return(status: 200, body: '', headers: {})
        end

        it { is_expected.to have_http_status(:ok) }
        it { expect(stub).to have_been_requested }
      end

      describe 'DELETE #destroy' do
        let(:data) { destroy_attributes(record, resource_name, resource_klass) }
        subject { delete :destroy, id: record.id, data: data }

        let(:stub) do
          stub_request(:delete, File.join(base_url, endpoint, record.id))
            .with(headers: headers)
            .to_return(status: 204, body: '', headers: {})
        end

        it { is_expected.to have_http_status(:no_content) }
        it { expect(stub).to have_been_requested }
      end
    end
  end
end

