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

    describe '#info' do
      subject { MnoEnterprise::AuditEventsListener.new.info('user_update_password', user.id, 'User password change', user.email, user) }

      it { expect(subject.code).to eq(200) }
      it { expect(subject.request.options[:body]).to eq(info_data(user)) }
    end
  end
end
