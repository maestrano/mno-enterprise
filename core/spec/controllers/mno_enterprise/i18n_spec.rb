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
        I18n.available_locales = [:en, :fr]
        I18n.default_locale = :en
      end

      context 'when a valid locale is provided' do
        it 'sets the provided locale' do
          get :index, locale: :fr
          expect(I18n.locale).to eq(:fr)
        end
      end

      context 'when an invalid locale is provided' do
        it 'sets the default locale' do
          get :index, locale: :it
          expect(I18n.locale).to eq(:en)
        end
      end

      context 'when the locale is not provided' do
        it 'sets the default locale' do
          get :index
          expect(I18n.locale).to eq(:en)
        end
      end
    end
  end
end
