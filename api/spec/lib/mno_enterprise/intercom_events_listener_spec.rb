require 'rails_helper'

module MnoEnterprise
  RSpec.describe IntercomEventsListener do
    let(:app) { build(:app) }
    let(:app_instance) { build(:app_instance, app: app, organization_id: organization.id) }
    let(:user) { build(:user) }
    let(:organization) { build(:organization) }
    before do
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      api_stub_for(get: "/users/#{user.id}/organizations", response: from_api([organization]))
      api_stub_for(get: "/organizations/#{organization.id}/app_instances", response: from_api([app_instance]))
    end


    describe '#info' do
      let(:events) { double('events') }
      context 'when the user already exist in intercom' do
        before do
          users = double('users')

          client = double('client', users: users, events: events)
          expect(Intercom::Client).to receive(:new).with(app_id: MnoEnterprise.intercom_app_id, api_key: MnoEnterprise.intercom_api_key).and_return(client)

          expect(users).to receive(:find)
        end

        subject { MnoEnterprise::IntercomEventsListener.new }

        it 'add an event when an password is changed' do
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
      context 'when the user does not exist in intercom' do
        before do
          users = double('users')

          client = double('client', users: users, events: events)
          expect(Intercom::Client).to receive(:new).with(app_id: MnoEnterprise.intercom_app_id, api_key: MnoEnterprise.intercom_api_key).and_return(client)

          expect(users).to receive(:find).and_raise(Intercom::ResourceNotFound.new('not found'))
          user_data =        {
            user_id: user.id,
            name: [user.name, user.surname].join(' '),
            email: user.email,
            created_at: user.created_at.to_i,
            last_seen_ip: user.last_sign_in_ip,
            custom_attributes: {phone: user.phone},
            update_last_request_at: true,
            companies:[
              {
                company_id: organization.id,
                name: organization.name,
                created_at: organization.created_at.to_i,
                custom_attributes: {
                  industry: organization.industry,
                  size: organization.size,
                  credit_card_details: organization.credit_card?,
                  app_count: organization.app_instances.count,
                  app_list: organization.app_instances.map { |app| app.name }.to_sentence
                }
              }

            ]
          }
          expect(users).to receive(:create).with(user_data)
        end
        it 'add an event when an password is changed' do
          expect(events).to receive(:create).with(hash_including(email: user.email, event_name: 'user-update-password'))
          subject.info('user_update_password', user.id, 'User password change', user.class.name, user.id, user.email)
        end
      end

    end
  end
end
