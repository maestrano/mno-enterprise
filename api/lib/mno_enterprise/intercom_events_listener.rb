require 'intercom'

module MnoEnterprise

  class IntercomEventsListener

    attr_accessor :intercom

    def initialize
      if MnoEnterprise.intercom_api_key && MnoEnterprise.intercom_api_secret
        self.intercom = ::Intercom::Client.new(app_id: MnoEnterprise.intercom_api_key, api_key: MnoEnterprise.intercom_api_secret)
      else
        self.intercom = nil
      end

    end

    def info(key, current_user_id, description, metadata, object)
      return unless self.intercom
      u = User.find(current_user_id)
      begin
        begin
          intercom.users.find(:user_id => current_user_id)
        rescue Intercom::ResourceNotFound
          self.update_intercom_user(u)
        end
        case key
          when 'user_update'
            self.update_intercom_user(u)
            return
          when 'app_destroy'
            event_name = 'deleted-app-' + object.app.nid
          when 'app_add'
            event_name = 'added-app-' + object.app.nid
          else
            event_name = key.gsub!(/_/, '-')
        end
        self.intercom.events.create(event_name: event_name, created_at: Time.now.to_i, email: u.email)


      rescue Intercom::IntercomError => e
        Rails.logger.debug '[INTERCOM] Could not call intercom: ' + e.message
      end
    end

    def update_intercom_user(user)
      data = {
        user_id: user.id,
        name: [user.name, user.surname].join(' '),
        email: user.email,
        created_at: user.created_at.to_i,
        last_seen_ip: user.last_sign_in_ip,
        custom_attributes: {}
      }
      data[:custom_attributes][:phone]= user.phone if user.phone


      data[:companies] = user.organizations.map do |organization|
        {
          company_id: organization.id,
          name: organization.name,
          created_at: organization.created_at,
          custom_attributes: {
            industry: organization.industry,
            size: organization.size,
            credit_card_details: organization.credit_card?,
            app_count: organization.app_instances.count,
            app_list: organization.app_instances.map { |app| app.name }.to_sentence
          }
        }
      end

      intercom.users.create(data)
    end

  end

end

