json.app_answers do
  json.array! @app_reviews do |app_answer|
    json.partial! 'resource', app_answer: app_answer
  end
end
json.metadata do
  json.pagination do
    json.count @total_count
  end
end
