require "rails_helper"

describe MnoEnterprise::SmtpClient do
	subject { described_class }

	describe '.deliver' do
		let(:template) { :some_template_name }
		let(:from) {{ name: "John", email: 'j@e.com' }}
	  let(:to) {{ name: "John", email: 'j@e.com' }}
	  let(:vars) {{ some: 'var' }}
	  let(:template_path) { :system_notifications }

		it 'sends the correct email with correct parameters' do
			expect(subject).to receive(:mail).with(
				"John <j@e.com>",
				to[:email],
				"Some template name",
				template_path,
				template
			)
			subject.deliver(template, from, to, vars)
		end
	end
end
