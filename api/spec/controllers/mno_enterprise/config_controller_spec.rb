require 'rails_helper'

module MnoEnterprise
  describe ConfigController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }

    describe 'GET #show' do
      subject { get :show, format: :js }

      it { is_expected.to be_successful }

      it 'is publicly cacheable' do
        subject
        header = response.headers['Cache-Control']

        expect(header).to eq('max-age=0, public, must-revalidate')
      end

      it 'renders the configuration' do
        subject
        body = response.body

        expect(body).to include(".constant('ADMIN_PANEL_CONFIG'")
        expect(body).to include(".constant('DASHBOARD_CONFIG'")
        expect(body).to include(".constant('IMPAC_CONFIG'")
        expect(body).to include(".constant('CONFIG_JSON_SCHEMA'")
      end
    end
  end
end
