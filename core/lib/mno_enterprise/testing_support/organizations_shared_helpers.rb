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

  def partial_hash_for_members(organization)
    list = []
    organization.users.each do |user|
      list.push({
                    'id' => user.id,
                    'entity' => 'User',
                    'name' => user.name,
                    'surname' => user.surname,
                    'email' => user.email,
                    'role' => user.role(organization)
                })
    end

    organization.org_invites.each do |invite|
      list.push({
                    'id' => invite.id,
                    'entity' => 'OrgInvite',
                    'email' => invite.user_email,
                    'role' => invite.user_role
                })
    end

    return list
  end

# def partial_hash_for_arrears_situations(situations)
#   array = []
#   situations.each do |sit|
#     array.push({
#       id: sit.id,
#       owner_id: sit.owner_id,
#       owner_type: sit.owner_type,
#       status: sit.status,
#       category: sit.category
#       })
#   end
#
#   return { arrears_situations: array }
# end

  def partial_hash_for_organization(organization, admin = false)
    ret = {
        'id' => organization.id,
        'name' => organization.name,
        'soa_enabled' => organization.soa_enabled
    }

    if admin
      ret.merge!({
                     'uid' => organization.uid
                 })
    end

    ret
  end

  def partial_hash_for_organization_in_arrears(organization, admin = false)
    {
        'id' => organization.id,
        'name' => organization.name,
        'soa_enabled' => organization.soa_enabled,
        'in_arrears?' => organization.in_arrears?
    }
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
    hash = {'invoices' => []}
    organization.invoices.order("ended_at DESC").each do |invoice|
      hash['invoices'].push({
                                'period' => invoice.period_label,
                                'amount' => invoice.total_due,
                                'paid' => invoice.paid?,
                                'link' => mnoe_enterprise.invoice_path(invoice.slug),
                            })
    end

    return hash
  end

  def hash_for_organizations(organizations, admin = false)
    {
        'organizations' => organizations.map { |o| partial_hash_for_organization(o, admin) }
    }
  end

  def hash_for_organizations_in_arrears(organizations, admin = false)
    {
        'organizations' => organizations.map { |o| partial_hash_for_organization_in_arrears(o, admin) }
    }
  end

  def hash_for_reduced_organization(organization)
    {
        'organization' => partial_hash_for_organization(organization)
    }
  end

  def hash_for_organization(organization, user, admin = false)
    hash = {
        'organization' => partial_hash_for_organization(organization, admin),
        'current_user' => partial_hash_for_current_user(organization, user)
    }
    hash['organization'].merge!(
        'members' => partial_hash_for_members(organization)
    )

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
end