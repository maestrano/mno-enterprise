require 'rails_helper'

describe MnoEnterprise::SmtpClient do
  let(:client) { described_class.send(:new) }
  let(:from_object) { { name: 'John', email: 'john.doe@example.com' } }
  let(:to_object) { { name: 'Joe', email: 'joe.blogg@example.com' } }
  let(:template_name) { 'reset-password-instructions' }
  let(:expected_params) do
    { from: 'John <john.doe@example.com>',
      to: 'joe.blogg@example.com',
      template_path: 'system_notifications',
      template_name: template_name }
  end

  describe '#deliver' do
    context 'opts has been inputted by user' do
      let(:opts) { {} }
      subject do
        client.deliver(
          template_name,
          from_object,
          to_object,
          { attachments: [{ name: 'some-file.pdf',
                            content: 'the file' }] },
          opts
        )
      end
      context 'subject has been specified by user' do
        let(:user_specified_subject) { 'This is a user specified subject' }

        before do
          opts[:subject] = user_specified_subject
        end

        it 'sets the subject to subject in opts' do
          expected_params[:subject] = user_specified_subject

          expect(client).to receive(:mail).with(expected_params)

          subject
        end
      end
    end

    context 'opts has not been inputted by user' do
      subject do
        client.deliver(
          template_name,
          from_object,
          to_object,
          attachments: [{ name: 'some-file.pdf',
                          content: 'the file' }]
        )
      end

      before do
        expected_params[:subject] = client.humanize(template_name)
      end

      it 'sets the subject of the email to the #humanize(template)' do
        expect(client).to receive(:mail).with(expected_params)

        subject
      end

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
