json.user_access_request do
  json.partial! 'user_access_request', user_access_request: @user_access_request if @user_access_request
end
