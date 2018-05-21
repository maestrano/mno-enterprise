json.organization do
  json.partial! 'organization', organization: @organization
  json.partial! 'main_address_attributes', main_address: @organization.main_address
end
