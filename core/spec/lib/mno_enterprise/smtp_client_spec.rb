require 'rails_helper'

describe MnoEnterprise::SmtpClient do
  let(:client) { described_class.send(:new) }

  describe '#deliver' do
    subject do
      client.deliver(
        'reset-password-instructions',
        {name: 'John', email: 'john.doe@example.com'},
        {name: 'Joe', email: 'joe.blogg@example.com'},
        attachments: [
          {
            name: 'some-file.pdf',
            content: 'the file'
          }
        ]
      )
    end

    it 'calls mail with the correct params' do
      expected_params = {
        from: 'John <john.doe@example.com>',
        to: 'joe.blogg@example.com',
        subject: 'Reset password instructions',
        template_path: 'system_notifications',
        template_name: 'reset-password-instructions'
      }

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

  describe '#format_sender' do
    it do
      sender = {name: 'John', email: 'john.doe@example.com'}
      expect(client.format_sender(sender)).to eq('John <john.doe@example.com>')
    end
  end
  describe '#humanize' do
    it 'returns a humanized template subject' do
      expect(client.humanize('reset-password-instructions')).to eq('Reset password instructions')
    end
  end
end
