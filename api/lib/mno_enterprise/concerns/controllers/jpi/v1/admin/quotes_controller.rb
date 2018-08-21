module MnoEnterprise::Concerns::Controllers::Jpi::V1::Admin::QuotesController
  extend ActiveSupport::Concern

  #==================================================================
  # Instance methods
  #==================================================================
  # POST /mnoe/jpi/v1/organizations/:id/quote
  # Sends post request to MnoHub
  def create
    @quote = MnoEnterprise::ProductQuote.fetch_quote!(params)
    if @quote.errors.empty?
      render :show
    else
      render json: @quote.errors, status: :bad_request
    end
  end
end
