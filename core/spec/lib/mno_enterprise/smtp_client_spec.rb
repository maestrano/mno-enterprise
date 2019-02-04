require 'rails_helper'

describe MnoEnterprise::SmtpClient do
  let(:client) { described_class.send(:new) }

  describe '#deliver' do
    let(:opts) { nil }
    let(:params) do
      [
        'reset-password-instructions',
        { name: 'John', email: 'john.doe@example.com' },
        { name: 'Joe', email: 'joe.blogg@example.com' },
        { attachments: [{ name: 'some-file.pdf', content: 'the file' }] },
        opts
      ].compact
    end
    let(:expected_params) do
      {
        from: 'John <john.doe@example.com>',
        to: 'joe.blogg@example.com',
        subject: client.humanize('reset-password-instructions'),
        template_path: 'system_notifications',
        template_name: 'reset-password-instructions'
      }
    end
    
    subject { client.deliver(*params) }

    context 'with no subject specified' do
      it 'calls mail with the correct params' do
        expect(client).to receive(:mail).with(expected_params)
        subject
      end

      it 'sends the attachments' do
        allow(client).to receive(:mail)
        attachments = {}
        expect(client).to receive(:attachments).and_return(attachments)
        subject
        expect(attachments).to eq('some-file.pdf' => 'the file')
      end
    end
    
    context 'with a subject specified in the opts' do
      let(:specified_subject) { 'This is a user specified subject' }
      let(:opts) { { subject: specified_subject } }

      before { expected_params[:subject] = specified_subject }

      it 'uses the specified subject' do
        expect(client).to receive(:mail).with(expected_params)
        subject
      end
    end
  end

  describe '#format_sender' do
    it do
      sender = { name: 'John', email: 'john.doe@example.com' }
      expect(client.format_sender(sender)).to eq('John <john.doe@example.com>')
    end
  end

  describe '#humanize' do
    it 'returns a humanized template subject' do
      expect(client.humanize('reset-password-instructions')).to eq('Reset password instructions')
    end
  end
end
