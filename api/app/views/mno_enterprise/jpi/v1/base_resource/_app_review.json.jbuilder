json.extract! app_review, :id, :description, :status,
              :user_id, :user_name, :organization_id, :organization_name,
              :app_id, :app_name, :user_admin_role, :created_at, :updated_at, :edited

show_rating = local_assigns.fetch(:show_rating, true)
if app_review.respond_to?(:rating) && show_rating
  json.rating app_review.rating
end

if app_review[:versions]
  json.versions do
    json.array! app_review[:versions] do |version|
      json.extract! version, :id, :event, :description, :created_at, :author
    end
  end
end
