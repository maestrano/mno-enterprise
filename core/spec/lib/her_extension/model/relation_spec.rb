require 'rails_helper'

module MnoEnterprise
  RSpec.describe Her::Model::Relation do
    pending "add specs for Her::Model::Relation monkey patch: #{__FILE__}"

    before(:all) { Object.const_set('DummyClass', Class.new).send(:include, Her::Model) }
    let(:dummy_class) { DummyClass }

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

    # We mostly test our request expectations
    describe '.first_or_create' do
      let(:relation) { Her::Model::Relation.new(dummy_class) }
      subject { relation.where(foo: 'bar').first_or_create(baz: 'bar') }

      context 'when matching record' do
        let(:record) { dummy_class.new(foo: 'bar') }
        before do
          expect(dummy_class).to receive(:request).with(hash_including(filter: {foo: 'bar'}, _method: :get)).and_return([record])
        end

        it 'returns the record' do
          expect(subject).to eq(record)
        end
      end

      context 'when no matching record' do
        before do
          expect(dummy_class).to receive(:request).with(hash_including(filter: {foo: 'bar'}, _method: :get)).and_return([])
          expect(dummy_class).to receive(:request).with(hash_including(foo: 'bar', baz: 'bar', _method: :post)).and_return(dummy_class.new)
        end

        it 'creates a new record' do
          expect(subject).to eq(dummy_class.new(foo: 'bar', baz: 'bar'))
        end
      end
    end

    # We mostly test our request expectations
    describe '.first_or_initialize' do
      let(:relation) { Her::Model::Relation.new(dummy_class) }
      subject { relation.where(foo: 'bar').first_or_initialize(baz: 'bar') }

      context 'when matching record' do
        let(:record) { dummy_class.new(foo: 'bar') }
        before do
          expect(dummy_class).to receive(:request).with(hash_including(filter: {foo: 'bar'}, _method: :get)).and_return([record])
        end

        it 'returns the record' do
          expect(subject).to eq(record)
        end
      end

      context 'when no matching record' do
        before do
          expect(dummy_class).to receive(:request).with(hash_including(filter: {foo: 'bar'}, _method: :get)).and_return([])
          # No POST stub
        end

        it 'build a new record' do
          expect(subject).to eq(dummy_class.new(foo: 'bar', baz: 'bar'))
        end
      end
    end
  end
end
