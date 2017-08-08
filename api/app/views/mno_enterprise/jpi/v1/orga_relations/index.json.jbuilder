json.orga_relations do
  json.array! @orga_relations do |orga_relation|
    json.partial! 'orga_relation', orga_relation: orga_relation, user: orga_relation.user, organization: orga_relation.organization
  end
end
