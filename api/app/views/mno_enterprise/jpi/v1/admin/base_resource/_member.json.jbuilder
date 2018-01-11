if member.is_a?(MnoEnterprise::User)
  json.uid member.uid
  json.entity 'User'
  json.role member.role(organization) if organization
  json.admin_role member.admin_role

  status = case
           when member.confirmed? then 'active'
           when member.confirmation_sent_at.nil? then 'pending'
           when !member.confirmed? then 'invited'
           end

  user = member

elsif member.is_a?(MnoEnterprise::OrgInvite)
  json.entity 'OrgInvite'
  json.role member.user_role
  user = member.user

  status = case member.status
           when 'staged'
            then user.confirmed? ? 'notify' : 'pending'
           when 'pending'
           then user.confirmed? ? 'notify-disabled' : 'invited'
           when 'accepted' then 'active'
           end

end

json.extract! user, :id, :created_at, :email, :name, :surname
json.status status
