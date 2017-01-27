json.app_reviews do
  json.array! @app_reviews do |app_review|
    json.partial! 'resource', app_review: app_review
  end
end
