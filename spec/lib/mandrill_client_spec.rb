require "rails_helper"

describe MandrillClient do
  subject { MandrillClient }
  
  describe 'email' do
    let(:template) { :some_template }
    let(:from) {{ name: "John", email: 'j@e.com' }}
    let(:to) {{ name: "John", email: 'j@e.com' }}
    let(:vars) {{ some: 'var' }}
    
    it 'sends the right template with the right parameters' do
      expect(subject).to receive(:send_template).with(template,[],{
        from_name: from[:name],
        from_email: from[:email],
        to: [{email: to[:email], type: :to, name: to[:name]}],
        global_merge_vars: [{name: vars.keys.first.to_s, content: vars.values.first}]
      })
      subject.deliver(template,from,to,vars)
    end
  end
  
  describe "send_template" do
    let!(:orig_delivery_method) { Rails.configuration.action_mailer.delivery_method }
    before { MandrillClient.instance_variable_set("@client",nil) }
    before { Rails.configuration.action_mailer.delivery_method = :foo_method }
    after { Rails.configuration.action_mailer.delivery_method = orig_delivery_method }
    
    it 'delegates the method to a mandrill client' do
      messages = double('messages')
      mandrill = double('mandrill', messages: messages)
      expect(Mandrill::API).to receive(:new).and_return(mandrill)
      
      args = ['template_name', [], { foo: 'bar' }]
      expect(messages).to receive(:send_template).with(*args)
      MandrillClient.send_template(*args)
    end
    
    describe 'with nil delivery method' do
      before { Rails.configuration.action_mailer.delivery_method = nil }
      
      it 'delegates the method to a mandrill client' do
        messages = double('messages')
        mandrill = double('mandrill', messages: messages)
        expect(Mandrill::API).to receive(:new).and_return(mandrill)
      
        args = ['template_name', [], { foo: 'bar' }]
        expect(messages).to receive(:send_template).with(*args)
        MandrillClient.send_template(*args)
      end
    end
    
    describe 'with :test delivery method' do
      before { Rails.configuration.action_mailer.delivery_method = :test }
      
      it 'does not send any email' do
        # test no expectation failure
        allow(Mandrill::API).to receive(:new).and_return(double('mandrill'))
        MandrillClient.send_template('1',[],{})
      end
    end
    
  end
end