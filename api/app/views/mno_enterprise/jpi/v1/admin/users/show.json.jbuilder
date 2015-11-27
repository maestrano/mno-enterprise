json.user do
  json.extract! @user, :id, :uid, :email, :phone, :name, :surname, :admin_role, :created_at, :confirmed_at, :last_sign_in_at
  json.organizations @user_organizations do |org|
    json.id org.id
    json.uid org.uid
    json.name org.name
    json.created_at org.created_at
  end
end
