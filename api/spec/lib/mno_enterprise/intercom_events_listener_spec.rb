require 'rails_helper'

module MnoEnterprise
  RSpec.describe IntercomEventsListener do
    let(:app) { build(:app) }
    let(:app_instance) { build(:app_instance, app: app) }
    let(:user) { build(:user, organizations: [organization])}
    let(:credit_card) { build(:credit_card)}
    let(:credit_card_id) { credit_card.id }

    let(:organization) {
      o = build(:organization, app_instances: [app_instance, build(:app_instance, app: app)], credit_card: credit_card)
      o.credit_card_id = credit_card_id
      o
    }
    before do
      stub_api_v2(:get, "/users/#{user.id}", user, [:organizations])
      stub_api_v2(:get, "/organizations/#{organization.id}", organization, [:credit_card, :app_instances, :users])
    end

    # Stub Intercom client
    let(:tags) { double('tags') }
    let(:events) { double('events') }
    let(:users) { double('users') }
    let(:client) { double('client', users: users, events: events, tags: tags) }
    before do
      expect(Intercom::Client).to receive(:new).with(app_id: MnoEnterprise.intercom_app_id, api_key: MnoEnterprise.intercom_api_key).and_return(client)
    end

    let(:expected_user_data) {
      {
        user_id: user.id,
        name: [user.name, user.surname].join(' '),
        email: user.email,
        created_at: user.created_at.to_i,
        last_seen_ip: user.last_sign_in_ip,
        custom_attributes: {
          first_name: user.name,
          surname: user.surname,
          confirmed_at: user.confirmed_at,
          phone: user.phone,
          admin_role: user.admin_role,
          external_id: user.external_id
        },
        update_last_request_at: true,
        companies:[
          {
            company_id: organization.id,
            name: organization.name,
            created_at: organization.created_at.to_i,
            custom_attributes: {
              industry: organization.industry,
              size: organization.size,
              credit_card_details: organization.has_credit_card_details?,
              credit_card_expiry: organization.credit_card.expiry_date,
              app_count: organization.app_instances.count,
              app_list: organization.app_instances.map { |app| app.name }.to_sentence,
              user_count: 0
            }
          }
        ]
      }
    }

    describe '#info' do
      before do
        allow(MnoEnterprise::User).to receive(:find).and_return(user)
        # It refreshes the user
        expect(users).to receive(:create).with(expected_user_data)
      end

      subject { described_class.new }

      it 'add an event when a password is changed' do
        expect(events).to receive(:create).with(hash_including(email: user.email, user_id: user.id, event_name: 'user-update-password'))
        subject.info('user_update_password', user.id, 'User password change', user.class.name, user.id, user.email)
      end

      it 'add an event when an app is added' do
        expect(events).to receive(:create).with(hash_including(email: user.email, user_id: user.id, event_name: 'added-app-' + app.nid, metadata: {type: 'single', app_list: app.nid}))
        subject.info('app_add', user.id, 'App Added', app_instance.class.name, app_instance.id, {name: app_instance.name, app_nid: app_instance.app.nid} )
      end

      it 'add an event when an app is launched' do
        expect(events).to receive(:create).with(hash_including(email: user.email, user_id: user.id, event_name: 'launched-app-' + app.nid))
        subject.info('app_launch', user.id, 'App Launched', app_instance.class.name, app_instance.id, {name: app_instance.name, app_nid: app_instance.app.nid} )
      end
    end

    describe '#update_intercom_user' do
      subject { described_class.new.update_intercom_user(user) }
      before { allow(users).to receive(:create) }

      it 'updates the user' do
        expect(users).to receive(:create).with(expected_user_data)
        subject
      end

      context 'when the user has an external_id' do
        before { user.external_id = '123456' }
        it 'updates the user' do
          expect(users).to receive(:create) do |options|
            expect(options[:custom_attributes][:external_id]).to eq('123456')
          end
          subject
        end
      end

      context 'when the user has a source' do
        before { user.metadata = {source: 'acme'}}
        it 'tags the user' do
          expect(tags).to receive(:tag).with(name: 'acme', users: [{user_id: user.id}])
          subject
        end
      end
    end

    # TODO: a bit redundant with the full hash above
    # To be refactored when extracting to a service
    describe '#format_company' do
      let(:intercom_data) { subject.format_company(organization) }
      let(:custom_attributes) { intercom_data[:custom_attributes] }

      it { expect(intercom_data[:company_id]).to eq(organization.id) }
      it { expect(intercom_data[:created_at]).to eq(organization.created_at.to_i) }
      it { expect(intercom_data[:name]).to eq(organization.name) }

      it { expect(custom_attributes[:app_count]).to eq(2) }
      it { expect(custom_attributes[:app_list]).to eq(organization.app_instances.map { |app| app.name }.to_sentence) }
      it { expect(custom_attributes[:user_count]).to eq(0) }

      context 'with a credit card' do
        it 'returns CC data' do
          expect(custom_attributes[:credit_card_details]).to be true
          expect(custom_attributes[:credit_card_expiry]).to be_a Date
        end
      end

      context 'without a credit card' do
        let(:credit_card_id) { nil }
        let(:credit_card) { nil }
        it 'does not return CC data' do
          expect(custom_attributes[:credit_card_details]).to be false
          expect(custom_attributes[:credit_card_expiry]).to be nil
        end
      end
    end
  end
end
