json.partial! 'app_review', app_review: app_feedback, show_rating: true

json.comments do
  json.array! app_feedback.comments do |app_comment|
    json.partial! 'app_comment', app_comment: app_comment
  end
end
