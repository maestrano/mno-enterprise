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
      end

      describe 'available locales' do
        before do
          Settings.system.i18n.available_locales = %w(en-AU en-US)
          Settings.system.i18n.preferred_locale = 'en-AU'
        end

        context 'when I18n is enabled' do
          before { Settings.system.i18n.enabled = true }
          it 'returns available locales' do
            subject
            expected = [
              {id: 'en-AU', name: 'English (Australia)', flag: ''},
              {id: 'en-US', name: 'English (US)', flag: ''},
            ]
            expect(assigns(:available_locales)).to eq(expected)
          end
        end

        context 'when I18n is disabled' do
          before { Settings.system.i18n.enabled = false }
          it 'only returns the default locale'do
            subject
            expected = [{id: 'en-AU', name: 'English (Australia)', flag: ''}]
            expect(assigns(:available_locales)).to eq(expected)
          end
        end
      end
    end
  end
end
