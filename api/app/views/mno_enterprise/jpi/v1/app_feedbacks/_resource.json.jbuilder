json.partial! 'app_review', app_review: app_feedback

json.comments do
  json.array! app_feedback[:comments] do |app_comment|
    json.partial! 'comment', app_comment: app_comment
  end
end
