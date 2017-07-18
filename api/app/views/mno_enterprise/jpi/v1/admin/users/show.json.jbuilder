json.user do
  json.partial! 'user', user: @user

  json.organizations @user_organizations do |org|
    json.id org.id
    json.uid org.uid
    json.name org.name
    json.account_frozen org.account_frozen
    json.created_at org.created_at
  end

  json.clients @user_clients do |org|
    json.id org.id
    json.uid org.uid
    json.name org.name
    json.created_at org.created_at
  end
end
