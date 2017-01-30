json.id app_comment[:id]
json.description app_comment[:description]
json.status app_comment[:status]
json.user_id app_comment[:user_id]
json.user_name app_comment[:user_name]
json.organization_id app_comment[:organization_id]
json.organization_name app_comment[:organization_name]
json.app_id app_comment[:app_id]
json.feedback_id app_comment[:feedback_id]
json.app_name app_comment[:app_name]
json.user_admin_role app_comment[:user_admin_role]
json.created_at app_comment[:created_at]
json.updated_at app_comment[:updated_at]
if app_comment[:versions]
  json.versions do
    json.array! app_comment[:versions] do |version|
      json.extract! version, :id, :event, :description
    end
  end
end

