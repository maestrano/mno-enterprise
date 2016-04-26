gem 'sparkpost', '~> 0.1.4'
require 'sparkpost'
require 'active_support' # For Hash#slice and #symbolize_keys
require 'active_support/core_ext/hash/keys'

# Tools to manage SparkPost account
class SparkPostUtils
  # Copy templates from one account to another
  #
  # @param [String] src_api_key Api Key for the account to copy the templates from
  # @param [String] dst_api_key Api Key for the account to copy the templates to
  # @param [String] email The sender email
  #
  # @example
  #   SparkPostUtils.migrate_templates('src_api_key', 'dst_api_key')
  def self.migrate_templates(src_api_key, dst_api_key, sender_email = 'sandbox@sparkpostbox.com')
    input = SparkPost::Client.new(src_api_key)
    output = SparkPost::Client.new(dst_api_key)

    templates = input.template.list

    templates.each do |t|
      next if t['id'] == 'my-first-email'
      puts "Copying #{t['id']}"
      template = input.template.get(t['id'])
      options = template['options'].merge(template.slice(*%w(published description name))).symbolize_keys
      from = {email: sender_email}
      output.template.create template['id'], from, template['content']['subject'], template['content']['html'], **options
    end
  end
end
