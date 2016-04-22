if member.is_a?(MnoEnterprise::User)
  json.uid member.uid
  json.entity 'User'
  json.role member.role(organization) if organization

  status = case
           when member.confirmed? then 'active'
           when member.confirmation_sent_at.nil? then 'pending'
           when member.confirmation_sent_at.present? then 'invited'
           end

  user = member

elsif member.is_a?(MnoEnterprise::OrgInvite)
  json.entity 'OrgInvite'
  json.role member.user_role

  status = case member.status
           when 'staged' then 'pending'
           when 'pending' then 'invited'
           when 'accepted' then 'active'
           end

  user = member.user
end

json.extract! user, :id, :created_at, :email, :name, :surname
json.status status
