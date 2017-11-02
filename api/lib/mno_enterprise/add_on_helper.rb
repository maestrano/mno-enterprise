module MnoEnterprise
  module AddOnHelper

    def AddOnHelper.send_request(instance, method, path, options = {})
      url = instance.metadata['app']['host'] + path
      options.merge!(basic_auth: { username: instance.app.uid, password: instance.app.api_key }) if instance.app
      HTTParty.public_send(method, url, options)
    rescue => e
      Rails.logger.info("Error on request #{url} with options #{options}: #{e}")
    end
  end
end