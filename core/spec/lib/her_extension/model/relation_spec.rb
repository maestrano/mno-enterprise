require 'rails_helper'

module MnoEnterprise
  RSpec.describe Her::Model::Relation do
    pending "add specs for Her::Model::Relation monkey patch: #{__FILE__}"

    let(:dummy_class) { Class.new { include Her::Model } }

    describe '.where' do
      it 'adds the filter to params[:filter]' do
        rel = Her::Model::Relation.new(dummy_class).where('uid.in' => [1, 2], 'foo' => 'bar')
        expect(rel.params[:filter]).to eq('uid.in' => [1, 2], 'foo' => 'bar')
      end

      it 'replaces empty array values with nil' do
        rel = Her::Model::Relation.new(dummy_class).where('id.in' => [])
        expect(rel.params[:filter]).to eq('id.in' => nil)
      end
    end
  end
end
