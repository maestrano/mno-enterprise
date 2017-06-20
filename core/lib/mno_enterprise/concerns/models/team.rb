module MnoEnterprise::Concerns::Models::Team
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    property :created_at, type: :time
    property :updated_at, type: :time
    property :organization_id
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

  def to_audit_event
    {
      name: name,
      organization_id: self.organization_id
    }
  end
end
