require 'rails_helper'

module MnoEnterprise
  RSpec.describe AppInstance, type: :model do
    let(:app_instance) { FactoryGirl.build(:app_instance) }

    describe '#running?' do
      let(:app_instance) { FactoryGirl.build(:app_instance, status: status) }
      subject { app_instance.running? }

      context 'when status is running' do
        let(:status) { :running }
        it { is_expected.to be true }
      end

      non_running_status = AppInstance::ACTIVE_STATUSES + AppInstance::TERMINATION_STATUSES - [:running]
      non_running_status.each do |status|
        context "when status is #{status}" do
          let(:status) { status }
          it { is_expected.to be false }
        end
      end
    end
  end
end
