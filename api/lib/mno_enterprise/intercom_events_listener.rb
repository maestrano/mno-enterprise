require 'intercom'

module MnoEnterprise

  class IntercomEventsListener

    attr_accessor :intercom

    def initialize
      args = if MnoEnterprise.intercom_token
        {token: MnoEnterprise.intercom_token}
      else
        {app_id: MnoEnterprise.intercom_app_id, api_key: MnoEnterprise.intercom_api_key}
      end
      self.intercom = ::Intercom::Client.new(args)
    end

    def info(key, current_user_id, description, subject_type, subject_id, metadata)
      u = ::MnoEnterprise::User.find_one(current_user_id, :organizations)
      data = {created_at: Time.now.to_i, email: u.email, user_id: u.id, event_name: key.tr('_', '-')}
      case key
        when 'user_update', 'organization_update'
          # convert values to string
          data[:metadata] = Hash[ metadata.collect {|k,v| [k, v.to_s] } ]
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
          data[:metadata] = {widget: metadata[:name]}
        when 'app_launch'
          data[:event_name] = 'launched-app-' + metadata[:app_nid]
        when 'app_destroy'
          data[:event_name] = 'deleted-app-'  + metadata[:app_nid]
          data[:metadata] = {type: 'single', app_list: metadata[:app_nid]}
        when 'app_add'
          data[:event_name] = 'added-app-' + metadata[:app_nid]
          data[:metadata] = {type: 'single', app_list: metadata[:app_nid]}
      end
      # Update user data in intercom
      # OPTIMIZE: we could fetch the user for intercom and only update fields that have changed
      self.update_intercom_user(u)
      # Push the event to intercom
      self.intercom.events.create(data)

    rescue Intercom::IntercomError => e
      Rails.logger.tagged('Intercom') { Rails.logger.warn 'Error while calling intercom ' + e.message}
    end

    def update_intercom_user(user, update_last_request_at = true)
      data = user.intercom_data(update_last_request_at)
      data[:companies] = user.organizations.map do |organization|
        format_company(organization)
      end
      intercom.users.create(data)
      tag_user(user)
    end

    # If a source is set, tag the user with it
    def tag_user(user)
      if user.metadata && user.metadata[:source].present?
        intercom.tags.tag(name: user.metadata[:source], users: [{user_id: user.id}])
      end
    end

    # Formatting
    # TODO: extract to a CRM service
    # TODO: Very expensive calls, needs to see if we can retrieve all the informations in one go
    def format_company(organization)
      organization = organization.load_required(:credit_card, :app_instances, :users)
      {
        company_id: organization.id,
        name: organization.name,
        created_at: organization.created_at.to_i,
        custom_attributes: {
          industry: organization.industry,
          size: organization.size,
          credit_card_details: organization.has_credit_card_details?,
          credit_card_expiry: organization.credit_card ? organization.credit_card.expiry_date: nil,
          app_count: organization.app_instances.count,
          app_list: organization.app_instances.map(&:name).sort.to_sentence,
          user_count: organization.users.count
        }
      }
    end
  end
end

