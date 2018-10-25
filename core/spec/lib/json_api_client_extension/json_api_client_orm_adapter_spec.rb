require 'rails_helper'
module MnoEnterprise
  RSpec.describe JsonApiClient::OrmAdapter do
    let(:klass) { MnoEnterprise::User }
    let(:adapter) { klass.to_adapter }

    describe 'an ORM class' do
      describe '#to_adapter' do
        it 'returns an adapter instance' do
          expect(adapter).to be_a(OrmAdapter::Base)
        end

        it 'returns an adapter for the receiver' do
          expect(adapter.klass).to eq(klass)
        end

        it 'is be cached' do
          expect(klass.to_adapter.object_id).to eq(klass.to_adapter.object_id)
        end
      end
    end

    describe "adapter instance" do
      let(:user) { FactoryGirl.build(:user) }

      describe '#get!(id)' do
        let!(:stub) { stub_api_v2(:get, "/users/#{user.id}", user, [*klass::INCLUDED_DEPENDENCIES]) }

        it 'returns the instance with id if it exists' do
          expect(adapter.get!(user.id)).to have_attributes(id: user.id, uid: user.uid)
          expect(stub).to have_been_requested
        end

        it 'allows to_key like arguments' do
          expect(adapter.get!(user.to_key)).to have_attributes(id: user.id, uid: user.uid)
          expect(stub).to have_been_requested
        end

        context 'when there is no instance with that id' do
          let(:api_url) { api_v2_url('/users/nonexistent-id', [*klass::INCLUDED_DEPENDENCIES], _locale: I18n.locale) }
          let(:error_body) do
            {
              errors: [
                {
                  title: 'Record not found',
                  detail: 'The record identified by nonexistent-id could not be found.',
                  code: '404',
                  status: '404'
                }
              ]
            }
          end
          let!(:stub) do
            stub_request(:get, api_url)
              .with(MnoEnterpriseApiTestHelper::MOCK_OPTIONS)
              .to_return(
                status: 404,
                headers: MnoEnterpriseApiTestHelper::JSON_API_RESULT_HEADERS,
                body: error_body.to_json
              )
          end

          it 'raises an error' do
            expect{ adapter.get!('nonexistent-id') }.to raise_error(JsonApiClient::Errors::NotFound)
          end
        end
      end

      describe '#get(id)' do
        let!(:stub) { stub_api_v2(:get, '/users', [user], [*klass::INCLUDED_DEPENDENCIES], {filter: {id: user.id}, 'page[number]': 1, 'page[size]': 1}) }

        it 'returns the instance with id if it exists' do
          expect(adapter.get(user.id)).to have_attributes(id: user.id, uid: user.uid)
          expect(stub).to have_been_requested
        end

        it 'allows to_key like arguments' do
          expect(adapter.get(user.to_key)).to have_attributes(id: user.id, uid: user.uid)
          expect(stub).to have_been_requested
        end

        it 'returns nil if there is no instance with that id' do
          stub_api_v2(:get, '/users', [], [*klass::INCLUDED_DEPENDENCIES], {filter: {id: 'nonexistent-id'}, 'page[number]': 1, 'page[size]': 1})
          expect(adapter.get('nonexistent-id')).to be_nil
        end
      end

      describe '#find_first' do
        context 'when a model matching conditions exists' do
          let(:user) { FactoryGirl.build(:user, name: 'Fred') }
          let!(:stub) { stub_api_v2(:get, '/users', [user], [], {filter: {name: 'Fred'}, 'page[number]': 1, 'page[size]': 1}) }

          it 'returns the first match' do
            expect(adapter.find_first(name: 'Fred')).to have_attributes(id: user.id, uid: user.uid, name: 'Fred')
            expect(stub).to have_been_requested
          end
        end

        context 'when no matches' do
          let!(:stub) { stub_api_v2(:get, '/users', [], [], {filter: {name: 'Fred'}, 'page[number]': 1, 'page[size]': 1}) }

          it 'returns nil' do
            expect(adapter.find_first(name: 'Fred')).to be nil
            expect(stub).to have_been_requested
          end
        end

        context 'when no conditions passed' do
          let!(:stub) { stub_api_v2(:get, '/users', [user], [], {'page[number]': 1, 'page[size]': 1}) }

          it 'returns the first model' do
            expect(adapter.find_first).to have_attributes(id: user.id, uid: user.uid)
            expect(stub).to have_been_requested
          end
        end
      end

      describe '#destroy(instance)' do
        let!(:delete_stub) { stub_api_v2(:delete, "/users/#{user.id}") }

        it 'destroys the instance if it exists' do
          expect(adapter.destroy(user)).to be true
          expect(delete_stub).to have_been_requested
        end

        it 'returns nil if passed with an invalid instance' do
          expect(adapter.destroy("nonexistent instance")).to be nil
        end
      end
    end
  end
end
