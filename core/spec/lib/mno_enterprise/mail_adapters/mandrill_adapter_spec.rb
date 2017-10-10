require "rails_helper"

describe MnoEnterprise::MailAdapters::MandrillAdapter do
  subject { described_class }

  describe '.deliver' do
    let(:template) { :some_template }
    let(:from) {{ name: "John", email: 'j@e.com' }}
    let(:to) {{ name: "John", email: 'j@e.com' }}
    let(:vars) {{ some: 'var' }}

    it 'send the correct template with the correct parameters' do
      expect(subject).to receive(:send_template).with(template,[],{
        from_name: from[:name],
        from_email: from[:email],
        to: [{email: to[:email], type: :to, name: to[:name]}],
        global_merge_vars: [{name: vars.keys.first.to_s, content: vars.values.first}]
      })
      subject.deliver(template, from, to, vars)
    end

    context 'with attachments' do
      let(:vars) do
        {
          some: 'var',
          attachments: [{
            name: 'some-file.pdf', content: 'the file', type: 'application/pdf'
          }]
        }
      end

      it 'send the correct template with the correct parameters' do
        expect(subject).to receive(:send_template).with(template,[],{
          from_name: from[:name],
          from_email: from[:email],
          to: [{email: to[:email], type: :to, name: to[:name]}],
          attachments: [
            {name: 'some-file.pdf', content: Base64.encode64('the file'), type: 'application/pdf'}
          ],
          global_merge_vars: [{name: vars.keys.first.to_s, content: vars.values.first}]
        })
        subject.deliver(template, from, to, vars)
      end
    end
  end

  describe '.send_template' do
    before { described_class.instance_variable_set("@client", nil) }
    let(:args) { ['template_name', [], { foo: 'bar', content: {} }] }

    subject { described_class.send_template(*args) }

    context 'when not .test?' do
      before { allow(described_class).to receive(:test?) { false } }

      it 'delegates the method to a sparkpost client' do
        # Stub Mandrill client
        messages = double('messages')
        mandrill = double('mandrill', messages: messages)
        expect(Mandrill::API).to receive(:new).and_return(mandrill)

        expect(messages).to receive(:send_template).with(*args)
        subject
      end
    end

    context 'when .test?' do
      before { allow(described_class).to receive(:test?) { true } }

      it 'does not send any emails' do
        # Dummy client without any methods
        allow(Mandrill::API).to receive(:new).and_return('mandrill')
        expect { subject }.to change(described_class.base_deliveries,:count).by(1)
      end
    end
  end
end
