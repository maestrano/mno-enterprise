require 'rails_helper'

module MnoEnterprise
  RSpec.describe SubscriptionEvent, type: :model do
    %w(approve reject).each do |action|
      describe "##{action}" do
        subject { subscription_event.public_send(action) }

        let(:subscription_event) { build(:subscription_event) }
        let!(:stub) { stub_api_v2(:post, "/subscription_events/#{subscription_event.id}/#{action}", nil) }

        it "calls #{action} on the subscription_event" do
          subject
          expect(stub).to have_been_requested
        end
      end
    end
  end
end
