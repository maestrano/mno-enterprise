json.app_answer do
  json.id @app_review[:id]
  json.description @app_review[:description]
  json.status @app_review[:status]
  json.user_id @app_review[:user_id]
  json.user_name @app_review[:user_name]
  json.organization_id @app_review[:organization_id]
  json.organization_name @app_review[:organization_name]
  json.app_id @app_review[:app_id]
  json.question_id @app_review[:question_id]
  json.app_name @app_review[:app_name]
  json.created_at @app_review[:created_at]
  json.updated_at @app_review[:updated_at]
end
