module MnoEnterprise::Concerns::Controllers::Jpi::V1::QuotesController
  extend ActiveSupport::Concern

  #==================================================================
  # Instance methods
  #==================================================================
  # POST /mnoe/jpi/v1/organizations/:id/quote
  # Sends post request to MnoHub
  def create
    @quote =  MnoEnterprise::ProductQuote.fetch_quote!(params)
    render :show
  end
end
