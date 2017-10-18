module MnoEnterprise
  class Identity < BaseResource
    property :created_at, type: :time
    property :updated_at, type: :time
    property :user_id

    def self.find_for_oauth(auth)
      find_by_or_create(uid: auth.uid, provider: auth.provider)
    end
  end
end
