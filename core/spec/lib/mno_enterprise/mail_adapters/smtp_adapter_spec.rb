require "rails_helper"

describe MnoEnterprise::MailAdapters::SmtpAdapter do
  describe '.deliver' do
    before { described_class.instance_variable_set("@client", nil) }

    let(:template) { :some_template }
    let(:from) {{ name: "John", email: "j@e.com" }}
    let(:to) {{ name: "John", email: "j@e.com" }}
    let(:vars) {{ some: 'var' }}
    let(:opts) {{ some: 'opt' }}

    subject { described_class.deliver(template, from, to, vars, opts) }   

    it 'delegates the method to a smtp client' do
      # Stub SmptClient
      smtp = double('smtpclient')
      smtp_mail = double('smtpmail')
      
      expect(MnoEnterprise::SmtpClient).to receive(:new).and_return(smtp)
      
      expect(smtp).to receive(:deliver).with(template, from, to, vars, opts).and_return(smtp_mail)
      expect(smtp_mail).to receive(:deliver)

      subject
    end
  end
end

