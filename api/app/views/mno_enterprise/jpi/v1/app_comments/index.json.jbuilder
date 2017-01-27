json.app_comments do
  json.array! @app_reviews do |app_comment|
    json.partial! 'resource', app_comment: app_comment
  end
end
