require 'rails_helper'

module MnoEnterprise
  RSpec.describe BaseResource, type: :model do
    pending "add specs for MnoEnterprise::BaseResource: #{__FILE__}"

    describe '.site' do
      let(:private_host) { nil }
      subject { described_class.site }
      around do |example|
        MnoEnterprise.configure { |c| c.mno_api_private_host = private_host }
        example.run
        MnoEnterprise.configure { |c| c.mno_api_private_host = nil }
      end

      describe 'without private host' do
        it { is_expected.to eq('https://api-enterprise.maestrano.test/api/mnoe/v2') }
      end

      describe 'with private host' do
        let(:private_host) { 'https://api-hub.account.test' }
        it { is_expected.to eq("#{private_host}/api/mnoe/v2") }
      end
    end

    describe '#cache_key' do
      context 'for existing record' do
        let(:user) { build(:user) }

        it 'uses updated_at' do
          expect(user.cache_key).to eq("mno_enterprise/users/#{user.id}-#{user.updated_at.utc.to_s(:nsec)}")
        end

        context 'when updated_at is nil' do
          before { user.updated_at = nil }
          it { expect(user.cache_key).to eq("mno_enterprise/users/#{user.id}") }
        end

        it 'uses the named timestamp' do
          expect(user.cache_key(:confirmed_at)).to eq("mno_enterprise/users/#{user.id}-#{user.confirmed_at.utc.to_s(:nsec)}")
        end
      end

      context 'for new record' do
        it { expect(User.new.cache_key).to eq('mno_enterprise/users/new') }
      end
    end

    describe JsonApiClientExtension::CustomParser do
      describe 'time parsing' do
        subject { BaseResource.find(1).first }

        let(:time_value) { '2017-09-06T00:16:22Z' }
        let(:resp) { { data: { id: 1, type: 'base_resources', attributes: { some_date: time_value } } } }

        before do
          stub_request(:get, "#{MnoEnterprise::BaseResource.site}/base_resources/1?_locale=en").
            to_return(status: 200, body: resp.to_json, headers: { content_type: 'application/vnd.api+json' })
        end

        describe 'with iso8601 date' do
          it { expect { subject }.not_to raise_error }
          it { expect(subject.some_date).to be_a(Time) }
        end

        describe 'with timezone expanded' do
          let(:time_value) { '2017-09-06T00:16:22+0000' }

          it { expect { subject }.not_to raise_error }
          it { expect(subject.some_date).to be_a(Time) }
        end
      end
    end

    describe 'LocaleMiddleware' do
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
