json.app_review do
  json.partial! 'resource', app_review: @app_review
end
json.average_rating @average_rating
