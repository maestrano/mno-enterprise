json.app_feedback do
  json.partial! 'resource', app_feedback: @app_review
end
json.average_rating @average_rating
