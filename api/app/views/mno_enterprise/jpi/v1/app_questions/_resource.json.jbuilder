json.id app_question[:id]
json.description app_question[:description]
json.status app_question[:status]
json.user_id app_question[:user_id]
json.user_name app_question[:user_name]
json.organization_id app_question[:organization_id]
json.organization_name app_question[:organization_name]
json.app_id app_question[:app_id]
json.app_name app_question[:app_name]
json.created_at app_question[:created_at]
json.updated_at app_question[:updated_at]
json.answers do
  json.array! app_question[:answers] do |app_answer|
    json.partial! 'answer', app_answer: app_answer
  end
end
