module MnoEnterprise
  class OrgaRelation < BaseResource

    property :created_at, type: :time
    property :updated_at, type: :time
    # json_api_client map all primary id as string

    property :role, type: :string

    has_one :organization
    has_one :user

  end
end
