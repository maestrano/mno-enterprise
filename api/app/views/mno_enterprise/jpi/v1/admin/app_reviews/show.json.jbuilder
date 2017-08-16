json.app_review do
  json.partial! 'app_review', app_review: @app_review, show_rating: true
end
