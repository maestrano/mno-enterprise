require 'rails_helper'

module MnoEnterprise
  RSpec.describe UserAccessRequest, type: :model do
    describe '#current_status' do
      subject { user_access_request.current_status }
      context 'when it was approved' do
        describe 'it was approved after 24 hours ago' do
          let(:user_access_request) { build(:user_access_request, status: 'approved', expiration_date: 2.hours.from_now) }
          it { is_expected.to eq 'approved' }
        end
        describe 'it was approved before 24 hours ago' do
          let(:user_access_request) { build(:user_access_request, status: 'approved', expiration_date: 1.days.ago) }
          it { is_expected.to eq 'expired' }
        end
      end

      context 'when it was requested' do
        describe 'it was created after 24 hours ago' do
          let(:user_access_request) { build(:user_access_request, status: 'requested', created_at: 1.hours.ago) }
          it { is_expected.to eq 'requested' }
        end
        describe 'it was approved before 24 hours ago' do
          let(:user_access_request) { build(:user_access_request, status: 'requested', created_at: 3.days.ago) }
          it { is_expected.to eq 'expired' }
        end
      end
      context 'when it was denied' do
        let(:user_access_request) { build(:user_access_request, status: 'denied', created_at: 1.hours.ago) }
        it { is_expected.to eq 'denied' }
      end
    end
  end
end
