if member.is_a?(MnoEnterprise::User)
  json.uid member.uid
  json.entity 'User'
  json.role organization.role(member) if organization

  status = case
           when member.confirmed? then 'active'
           when member.confirmation_sent_at.nil? then 'pending'
           when member.confirmation_sent_at.present? then 'invited'
           end

  user = member
  access_request_status = user.access_request_status(current_user)

elsif member.is_a?(MnoEnterprise::OrgaInvite)
  json.entity 'OrgaInvite'
  json.role member.user_role

  status = case member.status
           when 'staged' then 'pending'
           when 'pending' then 'invited'
           when 'accepted' then 'active'
           end

  user = member.user
  access_request_status = nil
end

json.extract! user, :id, :created_at, :email, :name, :surname
json.status status
json.access_request_status access_request_status
