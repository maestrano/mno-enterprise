module MnoEnterprise::TestingSupport::OrganizationsSharedHelpers

  def partial_hash_for_credit_card(cc)
    {
        'credit_card' => {
            'id' => cc.id,
            'title' => cc.title,
            'first_name' => cc.first_name,
            'last_name' => cc.last_name,
            'number' => cc.masked_number,
            'month' => cc.month,
            'year' => cc.year,
            'country' => cc.country,
            'verification_value' => 'CVV',
            'billing_address' => cc.billing_address,
            'billing_city' => cc.billing_city,
            'billing_postcode' => cc.billing_postcode,
            'billing_country' => cc.billing_country
        }
    }
  end

  def partial_hash_for_members(organization, admin = false)
    list = []
    organization.users.each do |user|
      u = {
          'id' => user.id,
          'entity' => 'User',
          'name' => user.name,
          'surname' => user.surname,
          'email' => user.email,
          'role' => organization.role(user)
      }
      u['uid'] = user.uid if admin
      list.push(u)
    end


    organization.orga_invites.each do |invite|
      list.push({
                    'id' => invite.id,
                    'entity' => 'OrgInvite',
                    'email' => invite.user_email,
                    'role' => invite.user_role
                })
    end

    return list
  end

  def partial_hash_for_organization(organization, admin = false, main_address = false)
    ret = {
        'id' => organization.id,
        'name' => organization.name,
        'soa_enabled' => organization.soa_enabled,
        'account_frozen' => organization.account_frozen,
        'payment_restriction' => organization.payment_restriction,
        'billing_currency' => organization.billing_currency
    }

    if admin
      ret['uid'] = organization.uid
    end

    if main_address
      ret['main_address_attributes'] = partial_hash_for_main_address_attributes(main_address)
    end
    ret
  end

  def partial_hash_for_current_user(organization, user)
    {
        'id' => user.id,
        'name' => user.name,
        'surname' => user.surname,
        'email' => user.email,
        'role' => user.role(organization)
    }
  end

  def partial_hash_for_billing(organization)
    {
        'billing' => {
            'current' => organization.current_billing,
            'credit' => organization.current_credit
        }
    }
  end

  def partial_hash_for_invoices(organization)
    orga_invoices = []
    organization.invoices.each do |invoice|
      orga_invoices.push({
                          'started_at' => invoice.started_at.strftime("%Y-%m-%dT%H:%M:%SZ"),
                          'ended_at' => invoice.ended_at.strftime("%Y-%m-%dT%H:%M:%SZ"),
                          'amount' => AccountingjsSerializer.serialize(invoice.total_due),
                          'paid' => invoice.paid?,
                          'link' => "/mnoe/jpi/v1/invoices/#{invoice.slug}"
                        })
    end
    orga_invoices
  end

  def partial_hash_for_main_address_attributes(address)
    {
      'id' => address.id,
      'street' => address.street,
      'city' => address.city,
      'state_code' => address.state_code,
      'postal_code' => address.postal_code,
      'country_code' => address.country_code,
    }
  end

  def hash_for_organizations(organizations, admin = false, main_address = false)
    {
        'organizations' => organizations.map { |o| partial_hash_for_organization(o, admin) }
    }
  end

  def hash_for_reduced_organization(organization)
    {
        'organization' => partial_hash_for_organization(organization)
    }
  end

  def hash_for_organization(organization, user, admin = false, main_address = false)
    hash = {
        'organization' => partial_hash_for_organization(organization, false, main_address),
        'current_user' => partial_hash_for_current_user(organization, user)
    }
    hash['organization']['members'] = partial_hash_for_members(organization)

    if user.role(organization) == 'Super Admin'
      hash.merge!(partial_hash_for_billing(organization))
      hash.merge!(partial_hash_for_invoices(organization))

      if (cc = organization.credit_card)
        hash.merge!(partial_hash_for_credit_card(cc))
      end

      if (situations = organization.arrears_situations)
        hash.merge!(partial_hash_for_arrears_situations(situations))
      end
    end

    return hash
  end

  def admin_hash_for_organization(organization)
    hash = {}
    hash['organization'] = partial_hash_for_organization(organization, true)
    hash['organization']['members'] = partial_hash_for_members(organization, true)
    hash['organization']['credit_card'] = {'presence' => false}
    hash['organization'].merge!(admin_partial_hash_for_invoices(organization))
    hash['organization'].merge!(admin_partial_hash_for_active_apps(organization))
    hash
  end

  def admin_partial_hash_for_invoices(organization)
    hash = {'invoices' => []}
    organization.invoices.order("ended_at DESC").each do |invoice|
      hash['invoices'].push({
                                'started_at' => invoice.started_at,
                                'ended_at' => invoice.ended_at,
                                'amount' => AccountingjsSerializer.serialize(invoice.total_due),
                                'paid' => invoice.paid?
                            })
    end
    hash
  end

  def admin_partial_hash_for_active_apps(organization)
    hash = {'active_apps' => []}
    organization.app_instances.select { |app| app.status == "running" }.each do |active_apps|
      hash['active_apps'].push({
                                   'id' => active_apps.id,
                                   'name' => active_apps.name,
                                   'stack' => active_apps.stack,
                                   'uid' => active_apps.uid,
                                   'app_name' => active_apps.app.name,
                                   'app_logo' => active_apps.app.logo
                               })
    end
    hash
  end

end
