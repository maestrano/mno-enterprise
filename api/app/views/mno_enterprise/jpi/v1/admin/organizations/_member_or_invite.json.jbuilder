if member.is_a?(MnoEnterprise::User)
  json.id member.id
  json.entity 'User'
  json.name member.name
  json.surname member.surname
  json.email member.email
  json.role organization.role(member)
elsif member.is_a?(MnoEnterprise::OrgaInvite)
  json.id member.id
  json.entity 'OrgInvite'
  json.email member.user_email
  json.role member.user_role
end
