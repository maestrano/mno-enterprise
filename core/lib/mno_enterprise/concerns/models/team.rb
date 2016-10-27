# == Schema Information
#
# Endpoint:
#  - /v1/teams
#  - /v1/organizations/:organization_id/teams
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  organization_id :integer
#

module MnoEnterprise::Concerns::Models::Team
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    attributes :id, :name, :organization_id

    #=====================================
    # Associations
    #=====================================
    belongs_to :organization, class_name: 'MnoEnterprise::Organization'
    has_many :users, class_name: 'MnoEnterprise::User'
    has_many :app_instances, class_name: 'MnoEnterprise::AppInstance'
  end

  #==================================================================
  # Class methods
  #==================================================================
  module ClassMethods
    # def some_class_method
    #   'some text'
    # end
  end

  #==================================================================
  # Instance methods
  #==================================================================
  # Add a user to the team
  # TODO: specs
  def add_user(user)
    self.users.create(id: user.id)
  end

  # Remove a user from the team
  # TODO: specs
  def remove_user(user)
    self.users.destroy(id: user.id)
  end

  # Set the app_instance permissions of this team
  # Accept a collection of hashes or an array of ids
  # TODO: specs
  def set_access_to(collection_or_array)
    # Empty arrays do not seem to be passed in the request. Force value in this case
    list = collection_or_array.empty? ? [""] : collection_or_array
    self.put(data: { set_access_to: list })
    self.reload
    self
  end
end
