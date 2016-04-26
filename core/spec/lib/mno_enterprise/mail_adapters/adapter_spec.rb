require "rails_helper"

describe MnoEnterprise::MailAdapters::Adapter do
  subject { described_class }

  describe '.test?' do
    subject { described_class.test? }

    around do |example|
      orig_delivery_method = Rails.configuration.action_mailer.delivery_method
      example.run
      Rails.configuration.action_mailer.delivery_method = orig_delivery_method
    end

    context 'with delivery method' do
      before { Rails.configuration.action_mailer.delivery_method = :method }
      it { is_expected.to be false }
    end
    context 'with nil delivery method' do
      before { Rails.configuration.action_mailer.delivery_method = nil }
      it { is_expected.to be false }
    end

    context 'with :test delivery method' do
      before { Rails.configuration.action_mailer.delivery_method = :test }
      it { is_expected.to be true }
    end
  end
end
