require 'rails_helper'

module MnoEnterprise
  describe MnoEnterprise::Jpi::V1::SystemIdentityController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }
    before { Rails.cache.clear }

    let(:user) { build(:user) }
    let!(:current_user_stub) { stub_user(user) }
    let!(:system_identity) { build(:system_identity) }

    describe 'GET #index' do
      before { sign_in user }

      before do
        stub_api_v2(:get, '/system_identity', [system_identity], [], {page: {number: 1, size: 1}})
      end

      subject { get :index }

      it { is_expected.to be_success }

      it 'returns the right response' do
        subject

        expect(JSON.parse(response.body)['system_identity']).to include({
          "id" => system_identity.id,
          "mnohub_endpoint" => system_identity.mnohub_endpoint,
          "connec_endpoint" => system_identity.connec_endpoint,
          "impac_endpoint" => system_identity.impac_endpoint,
          "nex_endpoint" => system_identity.nex_endpoint,
          "preferred_locale" => system_identity.preferred_locale
        })
      end
    end
  end
end
