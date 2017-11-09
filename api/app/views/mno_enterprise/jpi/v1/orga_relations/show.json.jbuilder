json.orga_relation do
  json.partial! 'orga_relation', orga_relation: @orga_relation, user: @orga_relation.user, organization: @orga_relation.organization
end
