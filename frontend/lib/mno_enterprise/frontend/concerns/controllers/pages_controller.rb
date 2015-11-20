module MnoEnterprise::Frontend::Concerns::Controllers::PagesController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    # including :launch from mnoe/api as before_filter with only redefine the filter
    before_filter :authenticate_user!, only: [:myspace, :launch]
    before_filter :redirect_to_lounge_if_unconfirmed, only: [:myspace, :launch]
  end

  #==================================================================
  # Instance methods
  #==================================================================
  # GET /myspace
  def myspace
    # Meta Information
    @meta[:title] = "Dashboard"
    @meta[:description] = "Dashboard"
    render layout: 'mno_enterprise/application_dashboard'
  end
end
