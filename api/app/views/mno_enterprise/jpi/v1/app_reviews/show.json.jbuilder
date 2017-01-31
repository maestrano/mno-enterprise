json.app_review do
  json.partial! 'app_review', app_review: @app_review, rating: true
end
json.average_rating @average_rating
