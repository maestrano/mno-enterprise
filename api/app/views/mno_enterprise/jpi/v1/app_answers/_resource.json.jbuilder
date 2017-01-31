json.id app_answer[:id]
json.description app_answer[:description]
json.status app_answer[:status]
json.user_id app_answer[:user_id]
json.user_name app_answer[:user_name]
json.organization_id app_answer[:organization_id]
json.organization_name app_answer[:organization_name]
json.app_id app_answer[:app_id]
json.question_id app_answer[:question_id]
json.app_name app_answer[:app_name]
json.user_admin_role app_answer[:user_admin_role]
json.created_at app_answer[:created_at]
json.updated_at app_answer[:updated_at]
if app_answer[:versions]
  json.versions do
    json.array! app_answer[:versions] do |version|
      json.extract! version, :id, :event, :description
    end
  end
end

