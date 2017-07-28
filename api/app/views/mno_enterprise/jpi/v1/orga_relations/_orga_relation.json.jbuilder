json.extract! orga_relation, :id
json.user do
  json.extract! user, :id, :name, :surname, :email, :role
end
json.organization do
  json.extract! organization, :id, :name
end
