json.number_reviews @reviews_number
json.app_reviews do
  json.array! @app_reviews do |app_review|
    json.partial! 'app_review', app_review: app_review
  end
end

