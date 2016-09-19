# == Schema Information
#
# Endpoint: /v1/identities
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  provider   :string(255)
#  uid        :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

module MnoEnterprise
  class Identity < BaseResource

    attributes :id, :user_id, :provider, :uid, :created_at, :updated_at

    belongs_to :user, class_name: 'MnoEnterprise::User'

    def self.find_for_oauth(auth)
      where(uid: auth.uid, provider: auth.provider).first_or_create
    end

  end
end
