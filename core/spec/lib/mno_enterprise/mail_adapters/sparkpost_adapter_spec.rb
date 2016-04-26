require "rails_helper"

describe MnoEnterprise::MailAdapters::SparkpostAdapter do
  subject { described_class }
  before { ENV["SPARKPOST_API_KEY"] = "secret" }

  describe '.deliver' do
    let(:template) { :some_template }
    let(:from) {{ name: "John", email: 'j@e.com' }}
    let(:to) {{ name: "John", email: 'j@e.com' }}
    let(:vars) {{ some: 'var' }}

    it 'send the correct template with the correct parameters' do
      expect(subject).to receive(:send_template).with(
       template,
       [],
       {
         recipients: [address: to],
         content: {
          from: from,
          template_id: template
         },
         substitution_data: vars
       }
      )
      subject.deliver(template, from, to, vars)
    end
  end

  describe '.send_template' do
    before { described_class.instance_variable_set("@client", nil) }

    subject { described_class.send_template('template_name', [], { foo: 'bar', content: {} }) }

    context 'when not .test?' do
      before { allow(described_class).to receive(:test?) { false } }

      it 'delegates the method to a sparkpost client' do
        # Stub SparkPost client
        transmission = double('transmission')
        sparkpost = double('sparkpost', transmission: transmission)
        expect(SparkPost::Client).to receive(:new).and_return(sparkpost)

        expect(transmission).to receive(:send_payload)
        subject
      end
    end

    context 'when .test?' do
      before { allow(described_class).to receive(:test?) { true } }

      it 'does not send any emails' do
        # Dummy client without any methods
        allow(SparkPost::Client).to receive(:new).and_return(double('sparkpost'))

        expect { subject }.to change(described_class.base_deliveries,:count).by(1)
      end
    end
  end
end
