json.app_questions do
  json.array! @app_reviews do |app_question|
    json.partial! 'resource', app_question: app_question
  end
end
