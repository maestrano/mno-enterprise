# == Schema Information
#
# Table name: deletion_requests
#
#  id             :integer         not null, primary key
#  token          :string(255)
#  status         :string(255)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#

module MnoEnterprise
  class DeletionRequest < BaseResource
    attributes :id, :token, :status, :user_id

    #==============================================================
    # Associations
    #==============================================================
    belongs_to :user, class_name: 'MnoEnterprise::User'

    #============================================
    # Instance methods
    #============================================
    # We want to use the token instead of the id
    def to_param
      self.token
    end
  end
end
