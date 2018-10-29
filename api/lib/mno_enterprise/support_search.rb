=begin
Used to authenticate support search for organizations, so that they can
'log in' to an organization.

Allowed searches:
1. Exact search on business external id; just search orgs.
2. Partial search on first name AND last name AND business name (at least 3 chars each); search orgs and user's orgs and find intersection.
3. Partial search on first name AND last name (at least 4 chars each); just search user's orgs.
4. EXACT search on first name AND last name; just search user's orgs.
5. EXACT search on first name AND last name AND business name; search orgs and user's orgs and find intersection.
=end

module MnoEnterprise
  class SupportSearch
    attr_reader :params

    def initialize(params)
      @params = format_params(params)
    end

    def authorized_search?
      valid_search_by_external_id? || valid_search_by_name_surname_org_name? ||
        valid_search_by_just_user_name? || valid_exact_search_by_name?
    end

    def search
      if valid_search_by_external_id?
        # Just search the orgs.
        search_orgs
      elsif valid_search_by_name_surname_org_name? || valid_exact_search_by_name_org_name?
        # Find intersection between user's orgs and orgs search.
        org_ids = search_users_with_orgs.map(&:id)
        @params[:org_search][:where][:id] = org_ids
        search_orgs
      elsif valid_search_by_just_user_name? || valid_exact_search_by_name?
        # Just search the users.
        search_users_with_orgs
      else
        # If no valid search, return an empty array.
        []
      end
    end

    private

    def format_params(params)
      {
        org_search: ((params[:org_search] && JSON.parse(params[:org_search])) || {}).with_indifferent_access,
        user_search: ((params[:user_search] && JSON.parse(params[:user_search])) || {}).with_indifferent_access
      }
    end

    def search_orgs
      MnoEnterprise::Organization.apply_query_params(org_search).to_a
    end

    def search_users_with_orgs
      MnoEnterprise::User.apply_query_params(user_search)
        .includes(:organizations, :orga_relations)
        .map(&:organizations).flatten
    end

    def valid_search_by_external_id?
      # Exact search by external id.
      external_id_exact.present?
    end

    def valid_exact_search_by_name?
      # Exact search by user name and surname.
      user_name_exact.present? && surname_exact.present?
    end

    def valid_exact_search_by_name_org_name?
      # Exact search by user name and surname.
      valid_exact_search_by_name? && org_name_exact.present?
    end

    def valid_search_by_name_surname_org_name?
      # Partial search by user name, surname, and org name; 3 or more characters.
      [user_name_partial, surname_partial, org_name_partial].all? do |search|
        search.present? && search.length >= 3
      end
    end

    def valid_search_by_just_user_name?
      # Partial search by user name, and surname; 4 or more characters.
      [user_name_partial, surname_partial].all? do |search|
        search.present? && search.length >= 4
      end
    end

    def org_name_partial
      org_search.dig('where', 'name.like')
    end

    def external_id_exact
      org_search.dig('where', 'external_id')
    end

    def org_name_exact
      org_search.dig('where', 'name')
    end

    def surname_partial
      user_search.dig('where', 'surname.like')
    end

    def user_name_partial
      user_search.dig('where', 'name.like')
    end

    def user_name_exact
      user_search.dig('where', 'name')
    end

    def surname_exact
      user_search.dig('where', 'surname')
    end

    def org_search
      params[:org_search]
    end

    def user_search
      params[:user_search]
    end
  end
end
