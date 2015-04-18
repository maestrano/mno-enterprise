json.current_user do
  json.id @user.id
  json.name @user.name
  json.surname @user.surname
  json.email @user.email
  json.logged_in !!@user.id
  json.created_at @user.created_at ? @user.created_at.iso8601 : nil
  json.company @user.company
  json.phone @user.phone
  json.phone_country_code @user.phone_country_code
  json.country_code @user.geo_country_code || 'US'
  json.website @user.website
  
  # Embed association if user is persisted
  if @user.id
    json.organizations do
      json.array! (@user.organizations || []) do |o|
        json.id o.id
        json.name o.name
        json.current_user_role o.role
      end
    end
    
    if @user.deletion_request.present?
      json.deletion_request do
        #json.extract! @user.deletion_request, :id, :token
      end
    end
  end
end
