require 'rails_helper'

module MnoEnterprise
  RSpec.describe User, type: :model do
    def reload_user
      # Reload User class to redefine the validation
      # Removes MnoEnterprise::User from object-space:
      MnoEnterprise.send(:remove_const, :User)
      # Reloads the module (require might also work):
      load 'app/models/mno_enterprise/user.rb'
    end

    describe 'password strength' do
      # Initialize this way so the class reload is taken into account (the factory doesnt reload the User class)
      subject {
        MnoEnterprise::User.new(attributes_for(:user, password: 'password', email: 'totolebeau@hotmail.com'))
      }

      before do
        stub_api_v2(:get, '/users', [], [], {filter:{email: 'totolebeau@hotmail.com'}, page:{number: 1, size: 1}})
      end

      context 'without password regex' do
        it 'does not validate the password strength' do
          expect(subject).to be_valid
        end
      end

      context 'with password regex' do
        before do
          Devise.password_regex = /(?=.*\d)(?=.*[a-z])(?=.*[A-Z])/
          reload_user
        end

        it 'validates the password strength' do
          expect(subject).to be_invalid
          expect(subject.errors[:password].first).to eq('must contains at least one uppercase letter, one lower case letter and a number')
        end

        after do
          # Reset to default
          Devise.password_regex = nil
          MnoEnterprise.send(:remove_const, :User)
          load 'app/models/mno_enterprise/user.rb'
        end
      end
    end

    describe 'IntercomUser' do
      before do
        allow(MnoEnterprise).to receive(:intercom_enabled?).and_return(true)
        allow(MnoEnterprise).to receive(:intercom_api_secret).and_return('mysecret')

        # Reload User class to include IntercomUser concern
        MnoEnterprise.send(:remove_const, :User)
        load 'app/models/mno_enterprise/user.rb'
      end
      after do
        # Reset to default
        MnoEnterprise.send(:remove_const, :User)
        load 'app/models/mno_enterprise/user.rb'
      end

      let(:user) { MnoEnterprise::User.new(attributes_for(:user, admin_role: MnoEnterprise::User::ADMIN_ROLE)) }

      describe :intercom_user_hash do
        it 'returns the user intercom secure hash' do
          expect(user.intercom_user_hash).not_to be_nil
        end
      end

      describe :intercom_data do
        let(:expected) {
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
            update_last_request_at: true
          }
        }

        it {
          expect(user.intercom_data).to eq(expected)
        }
      end
    end

    describe 'Omniauth' do
      let(:firstname) { "Jack" }
      let(:lastname) { "Beauregard" }
      let(:provider) { 'someprovider' }
      let(:auth) { OmniAuth::AuthHash.new(
        {
          provider: provider,
          uid: '123545',
          info: {
            first_name: firstname,
            last_name: lastname,
            email: 'jack.beauregard@maestrano.com'
          }
        }
      ) }


      describe '.find_for_oauth' do
        it { expect(described_class).to respond_to(:find_for_oauth) }

        subject { described_class.find_for_oauth(auth) }

        context 'without a signed in user' do

          context 'with a matching identity' do
            let(:user) { build(:user, email: auth.info.email) }
            let(:identity) { build(:identity, provider: auth.provider, uid: auth.uid, user_id: user.id) }

            before do
              stub_api_v2(:get, '/identities', [identity],[], {filter: {provider: auth.provider, uid: auth.uid}, page: {number: 1, size: 1}})
              stub_api_v2(:get, "/users/#{user.id}", [user],[])
            end

            it 'returns the matching user' do
              expect(subject.id).to eq(user.id)
            end

            it 'does not create a new user' do
              expect(described_class).not_to receive(:create_from_omniauth)
              subject
            end
          end

          context 'with no matching identity' do
            let(:identity) { build(:identity, provider: auth.provider, uid: auth.uid) }
            before { expect(Identity).to receive(:find_for_oauth) { identity } }

            context 'when a user with a matching email exists' do
              let(:user) { build(:user, email: auth.info.email) }
              before do
                stub_api_v2(:get, '/users',[user],[], {filter: {email: auth.info.email}, page: {number: 1, size: 1}})
                stub_api_v2(:post, '/identities', identity)
              end

              it 'associates the new identity with the user' do
                subject
                expect(identity.user_id).to eq(user.id)
              end

              it 'returns the matching user' do
                expect(subject.id).to eq(user.id)
              end

              it 'does not create a new user' do
                expect(described_class).not_to receive(:create_from_omniauth)
                subject
              end

              context 'with Intuit provider' do
                let(:provider) { 'intuit' }

                context 'when email is authorised' do
                  subject { described_class.find_for_oauth(auth, authorized_link_to_email: auth[:info][:email]) }
                  it 'does not raise an error' do
                    expect { subject }.not_to raise_error
                  end
                end

                context 'when email is not authorised' do
                  it 'raises an error' do
                    expect { subject }.to raise_error(SecurityError, 'reconfirm credentials')
                  end
                end
              end
            end

            context 'when no user with a matching email exists' do
              let(:user) { described_class.new }
              let(:identity) { build(:identity, provider: auth.provider, uid: auth.uid) }

              before do
                stub_api_v2(:get, '/users',[],[], {filter: {email: auth.info.email}, page: {number: 1, size: 1}})
                stub_api_v2(:post, '/identities', identity)
              end

              it 'creates and returns a new user' do
                expect(described_class).to receive(:create_from_omniauth).with(auth, {}).and_return(user)
                expect(subject).to eq(user)
              end
            end
          end
        end

        context 'with a signed in user' do
          let(:user) { FactoryGirl.build(:user) }
          subject { described_class.find_for_oauth(auth, {}, user) }

          context 'when the identity match the current user' do
            let(:identity) { build(:identity, provider: auth.provider, uid: auth.uid, user_id: user.id) }
            before { expect(Identity).to receive(:find_for_oauth) { identity } }

            it 'does not touch the identity' do
              # no stub
              subject
            end

            it 'returns the current user' do
              expect(subject).to eq(user)
            end

            it 'does not create a new user' do
              expect(described_class).not_to receive(:create_from_omniauth)
              subject
            end
          end

          context 'when the identity does not match the current user' do
            let(:identity) { build(:identity, provider: auth.provider, uid: auth.uid) }
            before { expect(Identity).to receive(:find_for_oauth) { identity } }

            before do
              stub_api_v2(:post, '/identities', identity)
            end

            it 're-assign the identity to the current user' do
              subject
              expect(identity.user_id).to eq(user.id)
            end

            it 'returns the current user' do
              expect(subject).to eq(user)
            end

            it 'does not create a new user' do
              expect(described_class).not_to receive(:create_from_omniauth)
              subject
            end
          end
        end
      end

      describe '.create_from_omniauth' do
        let(:user) { build(:user) }
        let(:created_user) {
          u = build(:user)
          u.attributes = user.attributes
          u
        }
        before do
          stub_api_v2(:get, '/users', [], [], {filter: {email: auth.info.email}, page: {number: 1, size: 1}})
          stub_api_v2(:post, '/users', created_user)
          allow(Devise.token_generator).to receive(:generate).and_return(['ABCD1234', nil])
        end

        subject { described_class.create_from_omniauth(auth) }

        it { expect(described_class).to respond_to(:create_from_omniauth) }

        it 'creates a new user with the proper fields' do
          expect(MnoEnterprise::User).to receive(:new).with(
            hash_including(
              name: auth.info.first_name,
              surname: auth.info.last_name,
              email: auth.info.email
            )).and_return(user)
          subject
        end

        it 'skips email confirmation' do
          expect_any_instance_of(MnoEnterprise::User).to receive(:skip_confirmation!)
          expect(subject).to be_confirmed
        end

        context 'with Intuit provider' do
          let(:provider) { 'intuit' }

          it 'does not skip email confirmation' do
            expect(user).not_to receive(:skip_confirmation!)
            subject
          end
        end

        context 'with some params' do
          let(:created_user) {
            u = build(:user)
            u.attributes = user.attributes
            u.company = comp_name
            u
          }
          let(:comp_name) { 'some company to be set' }
          subject { described_class.create_from_omniauth(auth, company: comp_name) }

          it 'creates a user with correct attributes' do
            expect(subject.company).to eq(comp_name)
          end
        end

        context 'when omniauth provides a user with no name' do
          let(:firstname) { nil }
          let(:lastname) { nil }

          it "creates a user with name='first_part_of_email' and surname=''" do
            expect(MnoEnterprise::User).to receive(:new).with(
              hash_including(
                name: 'jack.beauregard',
                surname: '',
                email: auth.info.email
              )).and_return(user)
            subject
          end
        end
      end
    end

    describe 'Devise' do
      subject { MnoEnterprise::User.new }
      describe 'registerable?' do
        context 'default' do
          before { reload_user }
          it 'is registerable' do
            expect(MnoEnterprise::User.ancestors).to include(Devise::Models::Registerable)
          end
        end

        context 'enabled' do
          before do
            Settings.merge!(dashboard: { registration: { disabled: true } })
            reload_user
          end
          it 'is registerable' do
            expect(MnoEnterprise::User.ancestors).to include(Devise::Models::Registerable)
          end
        end

        context 'disabled' do
          before do
            Settings.merge!(dashboard: { registration: { enabled: false } })
            reload_user
          end
          it 'is not registerable' do
            expect(MnoEnterprise::User.ancestors).not_to include(Devise::Models::Registerable)
          end
        end
      end
    end

    describe '#access_request_status' do
      subject { user.access_request_status(other_user) }
      let(:other_user) { build(:user) }
      context 'when the user does not contains user_access_requests' do
        let(:user) { build(:user) }
        it { is_expected.to eq 'never_requested' }
      end
      context 'when the user contains user_access_requests' do
        let(:user) { user = build(:user, user_access_requests: [user_access_request1, user_access_request2]) }
        let(:user_access_request1) { build(:user_access_request, requester_id: requester_id, status: 'approved', created_at: 1.hours.ago, approved_at: Time.now) }
        let(:user_access_request2) { build(:user_access_request, requester_id: requester_id, status: 'denied', created_at: 2.hours.ago) }
        context 'with the correct requester_id' do
          let(:requester_id) { other_user.id }
          it { is_expected.to eq 'approved' }
        end
        context 'with another requester_id' do
          let(:requester_id) { 'fake' }
          it { is_expected.to eq 'never_requested' }
        end
      end
    end

    describe '#clear_clients!' do
      subject { user.clear_clients! }

      let(:user) { build(:user) }
      let!(:stub) { stub_api_v2(:patch, "/users/#{user.id}/update_clients", [], [], {}, {data: {attributes: {set: []}}})}

      it 'clears the clients' do
        subject
        expect(stub).to have_been_requested
      end
    end

    describe '#update_clients!' do
      subject { user.update_clients!(params) }

      let(:params) { {data: {attributes: {add: [1, 2]}}} }
      let(:user) { build(:user) }
      let!(:stub) { stub_api_v2(:patch, "/users/#{user.id}/update_clients", [], [], {}, params)}

      it 'updates the clients' do
        subject
        expect(stub).to have_been_requested
      end
    end

    describe '#support?' do
      subject { user.support? }
      let(:user) { build(:user, admin_role: admin_role) }
      let(:admin_role) { MnoEnterprise::User::ADMIN_ROLE }

      context 'when the user is not support' do
        it { is_expected.to be false}
      end

      context 'when the user is support' do
        let(:admin_role) { MnoEnterprise::User::SUPPORT_ROLE }
        it { is_expected.to be true}
      end
    end

    describe '#staff?' do
      subject { user.staff? }
      let(:user) { build(:user, admin_role: admin_role) }
      let(:admin_role) { MnoEnterprise::User::ADMIN_ROLE }

      context 'when the user is not staff' do
        it { is_expected.to be false}
      end

      context 'when the user is staff' do
        let(:admin_role) { MnoEnterprise::User::STAFF_ROLE }
        it { is_expected.to be true}
      end
    end
  end
end
