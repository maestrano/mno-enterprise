require 'rails_helper'

module MnoEnterprise
  describe Jpi::V2::UsersController, type: :controller do
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV2ApiController

    it_behaves_like MnoEnterprise::Jpi::V2::ApiController, %i[index update]

    include_context 'v2 api controller requests context'

    describe 'GET #show' do
      let(:stub_resp) do
        { 'data' => { 'attributes' => { 'name' => user.name } } }
      end

      let(:stub) do
        stub_request(:get, File.join(base_url, endpoint, record.id))
          .with(headers: headers)
          .to_return(status: 200, body: stub_resp.to_json, headers: {})
      end

      context 'when intercom is disabled' do
        before do
          allow(MnoEnterprise).to receive(:intercom_enabled?).and_return(false)
          allow_any_instance_of(MnoEnterprise::User).to receive(:intercom_user_hash).and_return(nil)

          get :show, id: record.id
        end


        it { expect(stub).to have_been_requested }
        it { expect(JSON.parse(response.body)).to eq(stub_resp) }
      end

      context 'when intercom is enabled' do
        let(:user_hash) { nil }

        before do
          allow(MnoEnterprise).to receive(:intercom_enabled?).and_return(true)
          allow_any_instance_of(MnoEnterprise::User).to receive(:intercom_user_hash).and_return(user_hash)

          get :show, id: record.id
        end

        it { expect(stub).to have_been_requested }
        it { expect(JSON.parse(response.body)).to eq(stub_resp) }

        context 'when user authentication is configured' do
          let(:user_hash) { 'hash' }

          it 'adds the intercom_user_hash key to user attributes' do
            expected_resp_body = stub_resp.clone.deep_merge(
              'data' => { 'attributes' => { 'intercom_user_hash' => 'hash' } }
            )
            expect(JSON.parse(response.body)).to eq(expected_resp_body)
          end
        end
      end
    end
  end
end
