require 'rails_helper'

module MnoEnterprise
  RSpec.describe IntercomEventsListener do
    let(:app) { build(:app) }
    let(:app_instance) { build(:app_instance, app: app, organization_id: organization.id) }
    let(:user) { build(:user).tap {|u| u.extend(MnoEnterprise::Concerns::Models::IntercomUser)} }
    let(:credit_card) { build(:credit_card) }
    let(:organization) { build(:organization) }
    before do
      allow_any_instance_of(MnoEnterprise::AppInstance).to receive(:app).and_return(app)
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      api_stub_for(get: "/users/#{user.id}/organizations", response: from_api([organization]))
      api_stub_for(get: "/organizations/#{organization.id}/app_instances", response: from_api([app_instance]))
      api_stub_for(get: "/organizations/#{organization.id}/credit_card", response: from_api(credit_card))
      api_stub_for(get: "/organizations/#{organization.id}/users", response: from_api([user]))
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
          admin_role: user.admin_role
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
              user_count: 1
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
        before { user.meta_data = {source: 'acme'}}
        it 'tags the user' do
          expect(tags).to receive(:tag).with(name: 'acme', users: [{user_id: user.id}])
          subject
        end
      end
    end

    # TODO: a bit redundant with the full hash above
    # To be refactored when extracting to a service
    describe '#format_company' do
      let(:organization) do
        MnoEnterprise::Organization.new(attributes_for(:organization)).tap do |o|
          o.credit_card = credit_card
          o.app_instances = [build(:app_instance, name: 'Xero'), build(:app_instance, name: 'Shopify')]
          o.users = [build(:user)]
        end
      end

      let(:intercom_data) { subject.format_company(organization) }
      let(:custom_attributes) { intercom_data[:custom_attributes] }

      it { expect(intercom_data[:company_id]).to eq(organization.id) }
      it { expect(intercom_data[:created_at]).to eq(organization.created_at.to_i) }
      it { expect(intercom_data[:name]).to eq(organization.name) }

      it { expect(custom_attributes[:app_count]).to eq(2) }
      it { expect(custom_attributes[:app_list]).to eq("Shopify and Xero") }
      it { expect(custom_attributes[:user_count]).to eq(1) }

      context 'with a credit card' do
        it 'does not return CC data' do
          expect(custom_attributes[:credit_card_details]).to be true
          expect(custom_attributes[:credit_card_expiry]).to be_a Date
        end
      end

      context 'without a credit card' do
        let(:credit_card) { MnoEnterprise::CreditCard.new }

        it 'does not return CC data' do
          expect(custom_attributes[:credit_card_details]).to be false
          expect(custom_attributes[:credit_card_expiry]).to be nil
        end
      end
    end
  end
end
