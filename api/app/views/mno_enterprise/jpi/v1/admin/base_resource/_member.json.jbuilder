if member.is_a?(MnoEnterprise::User)
  json.uid member.uid
  json.entity 'User'
  json.role member.role(organization) if organization
  json.admin_role member.admin_role
  invite = MnoEnterprise::OrgInvite.find_by(user_id: member.id, organization_id: organization.id)

  status = case
           when member.confirmed?
            then invite.notification_sent_at.present? ? 'active' : 'notify'
           when member.confirmation_sent_at.nil? then 'pending'
           when !member.confirmed? then 'invited'
           end

  user = member
elsif member.is_a?(MnoEnterprise::OrgInvite)
  json.entity 'OrgInvite'
  json.role member.user_role
  user = member.user
  invite = member

  status = case member.status
           when 'staged' then 'pending'
           when 'pending'
            then invite.notification_sent_at.present? ? 'notified' : 'notify'
           when 'accepted'
            then invite.notification_sent_at.present? ? 'active' : 'notify'
           end

end

allow_impersonation = invite.present? ? user.confirmed? && invite.status == 'accepted' : true

json.extract! user, :id, :created_at, :email, :name, :surname
json.status status
json.allow_impersonation allow_impersonation
