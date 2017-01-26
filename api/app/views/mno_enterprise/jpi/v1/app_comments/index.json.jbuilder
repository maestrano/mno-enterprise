json.app_comments do
  json.array! @app_reviews do |app_comment|
    json.partial! 'resource', app_comment: app_comment
  end
end
json.metadata do
  json.pagination do
    json.count @total_count
  end
end
