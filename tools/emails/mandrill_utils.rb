gem 'mandrill-api', '~> 1.0.53'
require 'mandrill'

# Tools to manage Mandrill account
class MandrillUtils
  # Copy templates from one account to another
  #
  # @param [String] src_api_key Api Key for the Mandrill account to copy the templates from
  # @param [String] dst_api_key Api Key for the Mandrill account to copy the templates to
  #
  # @example
  #   MandrillUtils.migrate_templates('src_api_key', 'dst_api_key')
  def self.migrate_templates(src_api_key, dst_api_key)
    input = Mandrill::API.new(src_api_key)
    output = Mandrill::API.new(dst_api_key)

    templates = input.templates.list

    templates.each do |t|
      puts "Copying #{t['name']}"
      output.templates.add t['name'], t['from_email'],  t['from_name'], t['subject'], t['code'], t['text'], false, t['labels']
    end
    return true
  end
end
