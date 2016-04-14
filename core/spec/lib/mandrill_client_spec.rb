require "rails_helper"

describe MandrillClient do
  subject { MandrillClient }

  before { allow(subject).to receive(:warn) }

  describe '.deliver' do
    before { MnoEnterprise::MailClient.adapter = :mandrill }
    after { MnoEnterprise::MailClient.adapter = :test }

    let(:template) { :some_template }
    let(:from) {{ name: "John", email: 'j@e.com' }}
    let(:to) {{ name: "John", email: 'j@e.com' }}
    let(:vars) {{ some: 'var' }}
    
    it 'sends the right template with the right parameters' do
      expect(MnoEnterprise::MailAdapters::MandrillAdapter).to receive(:send_template).with(template,[],{
        from_name: from[:name],
        from_email: from[:email],
        to: [{email: to[:email], type: :to, name: to[:name]}],
        global_merge_vars: [{name: vars.keys.first.to_s, content: vars.values.first}]
      })
      subject.deliver(template,from,to,vars)
    end

    it 'prints a deprecation warning' do
      expect(subject).to receive(:warn)
      subject.deliver(template,from,to,vars)
    end
  end
  
  describe '.send_template' do
    let(:args) { ['template_name', [], { foo: 'bar' }] }

    it 'delegates the method to the email adapter' do
      adapter = double('adapter')
      expect(MnoEnterprise::MailClient).to receive(:adapter).and_return(adapter)

      expect(adapter).to receive(:send_template).with(*args)
      subject.send_template(*args)
    end

    it 'prints a deprecation warning' do
      expect(subject).to receive(:warn)
      subject.send_template(*args)
    end
  end
end
