require "rails_helper"

describe MnoEnterprise::MailAdapters::SmtpAdapter do
  describe '.deliver' do
    before { described_class.instance_variable_set("@client", nil) }

    let(:template) { :some_template }
    let(:from) {{ name: "John", email: "j@e.com" }}
    let(:to) {{ name: "John", email: "j@e.com" }}
    let(:vars) {{ some: 'var' }}

    subject { described_class.deliver(template, from, to, vars) }   

    it 'delegates the method to a smtp client' do
      # Stub SmptClient
      smtp = double('smtpclient')
      expect(MnoEnterprise::SmtpClient).to receive(:new).and_return(smtp)
      
      expect(smtp).to receive(:deliver).with(template, from, to, vars)
      subject
    end
  end
end
