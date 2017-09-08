json.user do
  json.partial! 'user', user: @user

  json.organizations @user_organizations do |org|
    json.extract! org, :id, :uid, :name, :account_frozen, :created_at
  end

  json.clients @user_clients do |org|
    json.extract! org, :id, :uid, :name, :account_frozen, :created_at
  end

end
