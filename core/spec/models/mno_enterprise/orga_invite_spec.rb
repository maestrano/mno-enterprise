require 'rails_helper'

module MnoEnterprise
  RSpec.describe OrgaInvite, type: :model do
    describe '#accept!' do
      let(:orga_invite) { FactoryGirl.build(:orga_invite) }
      subject { orga_invite.accept! }

      before { stub_api_v2(:patch, "/orga_invites/#{orga_invite.id}/accept", orga_invite) }

      it 'accept invitations' do
        subject
        assert_requested_api_v2(:patch, "/orga_invites/#{orga_invite.id}/accept", body: {data: { attributes: { user_id: orga_invite.user.id } }}.to_json)
      end
    end

    describe '#cancel!' do
      let(:orga_invite) { FactoryGirl.build(:orga_invite) }
      subject { orga_invite.cancel! }

      before { stub_api_v2(:patch, "/orga_invites/#{orga_invite.id}/decline", orga_invite) }

      it 'cancel invitation' do
        subject
        assert_requested_api_v2(:patch, "/orga_invites/#{orga_invite.id}/decline")
      end
    end

    describe '#expired?' do
      subject { orga_invite.expired? }

      context 'invitation is cancelled' do
        let(:orga_invite) { FactoryGirl.build(:orga_invite, status: 'cancelled') }

        it { is_expected.to be_truthy }
      end

      context 'invitation is 1 week old' do
        let(:orga_invite) { FactoryGirl.build(:orga_invite, status: 'pending', created_at: 1.week.ago) }

        it { is_expected.to be_truthy }
      end

      context 'invitation is valid' do
        let(:orga_invite) { FactoryGirl.build(:orga_invite, status: 'pending', created_at: 1.day.ago) }

        it { is_expected.to be_falsy }
      end
    end
  end
end
