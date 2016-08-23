require 'rails_helper'

module MnoEnterprise
  RSpec.describe App, :type => :model do
    describe '.categories' do
      let(:categories) { %w(Other CATEGORY category) }
      let(:app) { build(:app, categories: categories) }
      let(:list) { nil }
      subject { described_class.categories(list) }

      context 'when no list' do
        before { allow(described_class).to receive(:all).and_return([app]) }

        it 'returns a unique (case insensitive) sorted list' do
          expect(subject).to eq(%W(CATEGORY Other))
        end
      end

      context 'with a list' do
        let(:app2) { build(:app, categories: ['Other Category', 'One']) }
        let(:list)  { [app2] }
        it 'scopes the categories to the list of app' do
          expect(subject).to eq(['One', 'Other Category'])
        end
      end
    end

    describe 'appinfo methods' do
      %i(single_billing? coming_soon? add_on?).each do |method|
        it { expect(described_class.new).to respond_to(method) }
      end
    end

    describe '#sanitized_description' do
      let(:app) { build(:app, description: "Some description by Maestrano") }
      it 'replaces any mention of maestrano by the name of the platform' do
        expect(app.sanitized_description).to eq("Some description by #{MnoEnterprise.app_name}")
      end
    end

    describe '#regenerate_api_key!' do
      let(:app) { build(:app) }
      let(:response) { build(:app, api_key: 'secret-key') }

      before { api_stub_for(put: "/apps/#{app.id}", response: from_api(response)) }

      subject { app.regenerate_api_key! }

      it 'regenerate the api key' do
        expect(app).to receive(:put).with(operation: 'regenerate_api_key').and_call_original
        subject
      end

      it 'refreshes the #api_key field' do
        old = app.api_key
        subject
        expect(app.api_key).to_not eq(old)
        expect(app.api_key).to eq(response.api_key)
      end
    end
  end
end
