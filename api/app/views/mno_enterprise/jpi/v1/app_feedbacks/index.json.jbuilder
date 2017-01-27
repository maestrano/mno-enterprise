json.app_feedbacks do
  json.array! @app_reviews do |app_feedback|
    json.partial! 'resource', app_feedback: app_feedback
  end
end
