require 'rails_helper'

module MnoEnterprise
  describe 'ApplicationController I18n', type: :controller do
    # Anonymous controller
    controller do
      include MnoEnterprise::Concerns::Controllers::I18n

      def index
        render text: 'Hello World'
      end
    end

    describe 'I18n' do
      before do
        I18n.available_locales = [:en, :fr, :zh]
        I18n.default_locale = :en
      end

      subject { I18n.locale }

      context 'when I18n is disabled' do
        before { MnoEnterprise.i18n_enabled = false }

        context 'when a valid locale is provided' do
          before { get :index, locale: :fr }
          it { is_expected.to eq(:en) }
        end

        context 'when default language gets changed' do
          before { I18n.default_locale = :zh }
          before { get :index, locale: :fr }
          it { is_expected.to eq(:zh) }
        end
      end

      context 'when I18n is enabled' do
       before { MnoEnterprise.i18n_enabled = true }

        context 'when a valid locale is provided' do
          before { get :index, locale: :fr }
          it { is_expected.to eq(:fr) }
        end

        context 'when an invalid locale is provided' do
          before { get :index, locale: :it }
          it { is_expected.to eq(:en) }
        end

        context 'when the locale is not provided' do
          before { get :index }
          it { is_expected.to eq(:en) }
        end
      end
    end
  end
end
