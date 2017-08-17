require 'rails_helper'

module MnoEnterprise
  RSpec.describe BaseResource, type: :model do

    pending "add specs for MnoEnterprise::BaseResource: #{__FILE__}"

    describe LocaleMiddleware do
      before do
        I18n.available_locales = [:'en-AU', :en]
        I18n.locale = 'en-AU'
      end

      describe '.find' do
        subject { BaseResource.find(1) }
        let!(:stub) { stub_api_v2(:get, '/base_resources/1', nil, [], _locale: 'en-AU') }

        it 'adds the locale to the query string' do
          subject
          expect(stub).to have_been_requested
        end
      end

      describe '.where' do
        subject { BaseResource.where(foo: 'bar').all }
        let!(:stub) { stub_api_v2(:get, '/base_resources', nil, [], _locale: 'en-AU', filter: {foo: 'bar'}) }

        it 'adds the locale to the query string' do
          subject
          expect(stub).to have_been_requested
        end
      end
    end
  end
end
