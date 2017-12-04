module MnoEnterprise
  class Jpi::V1::BaseResourceController < ApplicationController
    before_filter :check_authorization

    protected

    # test if the provided argument is a id or an uid
    # @param [Object] id or uid
    def is_id?(string)
      string.to_i.to_s == string
    end

    def parent_organization_id
      id_or_uid = params[:organization_id]
      if is_id?(id_or_uid)
        id_or_uid
      else
        parent_organization.id
      end
    end

    def parent_organization
      @parent_organization ||= begin
        id_or_uid = params[:organization_id]
        query = is_id?(id_or_uid) ? id_or_uid : { uid: id_or_uid }
        MnoEnterprise::Organization.find(query).first
      end
    end

    def orga_relation
      @orga_relation ||= begin
        id_or_uid = params[:organization_id]
        organization_field = is_id?(id_or_uid) ? 'id' : 'uid'
        MnoEnterprise::OrgaRelation.where('user.id' => current_user.id, "organization.#{organization_field}" => id_or_uid).first
      end
    end

    # Check current user is logged in
    # Check organization is valid if specified
    def check_authorization
      unless current_user
        render nothing: true, status: :unauthorized
        return false
      end
      if params[:organization_id] && !orga_relation
        render nothing: true, status: :forbidden
        return false
      end
      true
    end
  end
end
