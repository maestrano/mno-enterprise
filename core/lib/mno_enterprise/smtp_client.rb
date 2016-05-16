require 'action_mailer/railtie'

module MnoEnterprise
	# Base class (instantiable) for SMTP adapter
	class SmtpClient < ActionMailer::Base
		# Send SMTP template - terminal mailing part
		def deliver(template, from, to, vars={}, opts={}, template_path)
			@info = vars

			text_template_content = template_content(template_path, "text")
			html_template_content = template_content(template_path, "html")

			mail(
				:from => format_sender(from), 
				:to => to[:email], 
				:subject => humanize(template)) do |format|
				format.text { render :inline => text_template_content, :locals => @info }
			    format.html { render :inline => html_template_content, :locals => @info }
			end
		end 

		# Returns template content
		# @ext : "text" or "html"
		def template_content(path, ext)
			File.open(path + "." + ext + ".erb").read
			
			# @Reserve : for bindings like inline-images
			#template = ERB.new(html)
 			#template.result(controller_binding)
		end

		# Returns Actionmailer-compliant :from string
		# @Format : "Sender name <sender@email.com>"
		def format_sender(from)
			from[:name] + ' <' + from[:email] + '>'
		end
		
		# Returns humanized template subject
		# @i.e. "reset-password-instructions" to "Reset password instructions"
		def humanize(template_slug)
			template_slug.gsub("-", "_").humanize
		end
	end
end