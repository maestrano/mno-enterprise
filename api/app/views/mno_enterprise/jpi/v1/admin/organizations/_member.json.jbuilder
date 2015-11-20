if member.is_a?(MnoEnterprise::User)
  json.id member.id
  json.uid member.uid
  json.entity 'User'
  json.name member.name
  json.surname member.surname
  json.email member.email
  json.role member.role(organization)
elsif member.is_a?(MnoEnterprise::OrgInvite)
  json.id member.id
  json.entity 'OrgInvite'
  json.email member.user_email
  json.role member.user_role
end
