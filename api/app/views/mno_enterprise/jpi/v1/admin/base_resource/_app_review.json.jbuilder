json.extract! app_review, :id, :description, :status,
              :app_id, :app_name, :user_id, :user_name,
              :organization_id, :organization_name, :created_at, :updated_at
json.type app_review.review_type

if app_review.respond_to?(:rating) && show_rating
  json.rating app_review.rating
end
