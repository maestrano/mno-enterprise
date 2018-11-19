json.organizations do
  json.array! @organizations do |organization|
    json.partial! 'organization', organization: organization
  end
end
json.metadata @organizations.metadata if @organizations.respond_to?(:metadata)
