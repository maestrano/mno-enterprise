json.extract! orga_relation, :id, :role
json.user do
  json.extract! user, :id, :name, :surname, :email
end
json.organization do
  json.extract! organization, :id, :name
end
