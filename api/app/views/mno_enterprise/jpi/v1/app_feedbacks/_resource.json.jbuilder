json.id app_feedback[:id]
json.rating app_feedback[:rating]
json.description app_feedback[:description]
json.status app_feedback[:status]
json.user_id app_feedback[:user_id]
json.user_name app_feedback[:user_name]
json.organization_id app_feedback[:organization_id]
json.organization_name app_feedback[:organization_name]
json.app_id app_feedback[:app_id]
json.app_name app_feedback[:app_name]
json.user_admin_role app_feedback[:user_admin_role]
json.created_at app_feedback[:created_at]
json.updated_at app_feedback[:updated_at]
json.comments do
  json.array! app_feedback[:comments] do |app_comment|
    json.partial! 'comment', app_comment: app_comment
  end
end
