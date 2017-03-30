require 'rails_helper'

module MnoEnterprise
  RSpec.describe AuditEventsListener do

    def info_data(user)
      {
        data: {
          key: 'user_update_password',
          user_id: user.id,
          description: 'User password change',
          metadata: user.email,
          subject_type: user.class.name,
          subject_id: user.id
        }
      }
    end

    let(:user) { build(:user) }
    let(:organization) { build(:organization) }

    describe '#info' do
      subject { MnoEnterprise::AuditEventsListener.new.info('user_update_password', user.id, 'User password change', user.class.name, user.id, user.email) }

      it { expect(subject.code).to eq(200) }
      it { expect(subject.request.options[:body]).to eq(info_data(user)) }

      context 'with an organization_id in the metadata' do
        subject { MnoEnterprise::AuditEventsListener.new.info('user_update_password', user.id, 'User password change', user.class.name, user.id, {organization_id: 'foobar'}) }
        it { expect(subject.request.options[:body][:data][:organization_id]).to eq('foobar') }
      end

      context 'with an Organization subject' do
        subject { MnoEnterprise::AuditEventsListener.new.info('app_launch', user.id, 'App Launched', organization.class.name, organization.id, nil) }
        it { expect(subject.request.options[:body][:data][:organization_id]).to eq(organization.id) }
      end
    end
  end
end
