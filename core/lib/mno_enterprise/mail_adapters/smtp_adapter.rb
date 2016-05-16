module MnoEnterprise
	module MailAdapters
		# SMTP Adapter for MnoEnterprise::MailClient
		class SmtpAdapter < Adapter
			class << self
				# Return a smtp client configured with the SMTP settings
				# @return [SmtpClient]
				def client
					@client = MnoEnterprise::SmtpClient.send :new
				end

				# Return base path for template files
				# @To-do: template override logic will be implemented via this method 
				def template_path(template)
					Pathname.new(File.join( File.dirname( __FILE__ ), "templates", template)).to_s
				end

				# Send a template
				# @See Adapter#deliver
				def deliver(template, from, to, vars={}, opts={})
					client.deliver(template, from, to, vars, opts, template_path(template)).deliver
				end

			end
		end
	end
end