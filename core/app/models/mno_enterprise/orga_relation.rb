module MnoEnterprise
  class OrgaRelation < BaseResource

    property :created_at, type: :time
    property :updated_at, type: :time
    # json_api_client map all primary id as string
    property :organization_id, type: :string
    property :user_id, type: :string
    property :role, type: :string
  end
end
