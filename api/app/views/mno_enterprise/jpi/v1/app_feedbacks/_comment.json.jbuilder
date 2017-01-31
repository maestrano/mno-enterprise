json.partial! 'app_review', app_review: app_comment, show_rating: false

json.feedback_id app_comment[:feedback_id]
if app_comment[:versions]
  json.versions do
    json.array! app_comment[:versions] do |version|
      json.extract! version, :id, :event, :description
    end
  end
end
