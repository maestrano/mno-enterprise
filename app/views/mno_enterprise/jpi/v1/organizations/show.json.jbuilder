json.organization do
  json.partial! 'organization', organization: @organization
  json.members [@organization.users,@organization.org_invites].flatten, partial: 'member', as: :member, organization: @organization
end

json.current_user do
  json.partial! 'current_user', user: current_user, organization: @organization
end



# json.partial! 'current_user', user: @current_user, organization: @organization
# json.partial! 'members', organization: @organization

# if @current_user.role(@organization) == 'Super Admin'
#   json.partial! 'billing', organization: @organization
#   json.partial! 'invoices', organization: @organization
#   json.partial! 'credit_card', credit_card: @organization.credit_card
#   json.partial! 'arrears', arrears_situations: @organization.arrears_situations.in_progress
# end