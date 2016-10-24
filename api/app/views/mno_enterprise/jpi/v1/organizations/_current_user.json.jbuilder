json.id user.id
json.name user.name
json.surname user.surname
json.email user.email
json.role organization.members.to_a.find { |e| e.id == user.id }.role
