json.organization do
  json.partial! 'organization', organization: @organization
  json.members @organization.members(true), partial: 'member', as: :member, organization: @organization
  json.partial! 'main_address_attributes', main_address: @organization.main_address
end

json.current_user do
  json.partial! 'current_user', user: current_user, organization: @organization
end

if current_user.role(@organization) == 'Super Admin'
  json.partial! 'billing', organization: @organization
  json.partial! 'invoices', organization: @organization
  json.partial! 'credit_card', credit_card: @organization.credit_card
  #json.partial! 'arrears', arrears_situations: @organization.arrears_situations.in_progress
end
