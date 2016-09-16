require 'intercom'

module MnoEnterprise

  class IntercomEventsListener

    attr_accessor :intercom

    def initialize
      self.intercom = ::Intercom::Client.new(app_id: MnoEnterprise.intercom_app_id, api_key: MnoEnterprise.intercom_api_key)
    end

    def info(key, current_user_id, description, metadata, object)
      u = User.find(current_user_id)
      begin
        intercom.users.find(:user_id => current_user_id)
      rescue Intercom::ResourceNotFound
        self.update_intercom_user(u)
      end
      data = {created_at: Time.now.to_i, email: u.email}
      case key
        when 'user_update'
          self.update_intercom_user(u)
          return
        when 'user_confirm'
          data[:event_name] = 'finished-sign-up'
        when 'dashboard_create'
          data[:event_name] = 'added-dashboard'
        when 'dashboard_delete'
          data[:event_name] = 'removed-dashboard'
        when 'widget_delete'
          data[:event_name] = 'removed-widget'
        when 'widget_create'
          data[:event_name] = 'added-widget'
          data[:metadata] = {widget: object.name}
        when 'app_destroy'
          data[:event_name] = 'deleted-app-' + object.app.nid
          data[:metadata] = {type: 'single', app_list: object.app.nid}
        when 'app_add'
          data[:event_name] = 'added-app-' + object.app.nid
          data[:metadata] = {type: 'single', app_list: object.app.nid}
        else
          data[:event_name] = key.tr!('_', '-')
      end

      self.intercom.events.create(data)

    rescue Intercom::IntercomError => e
      Rails.logger.debug '[INTERCOM] Could not call intercom: ' + e.message
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
          created_at: organization.created_at.to_i,
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

