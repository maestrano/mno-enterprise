require 'rails_helper'

module MnoEnterprise
  RSpec.describe JsonApiClient::OrmAdapter do
    pending "add specs for JsonApiClient::OrmAdapter: #{__FILE__}"

    let(:dummy_class) do
      Class.new(MnoEnterprise::BaseResource) do
        def self.name
          'DummyClass'
        end
      end
    end
    let(:adapter) { dummy_class.to_adapter }

    describe '.find_first' do
      # Fetch only one record
      let!(:stub) { stub_api_v2(:get, '/dummy_classes', [], [], {filter: {name: 'Test'}, 'page[number]': 1, 'page[size]': 1}) }

      before { adapter.find_first(name: 'Test') }
      it { expect(stub).to have_been_requested }
    end
  end
end
