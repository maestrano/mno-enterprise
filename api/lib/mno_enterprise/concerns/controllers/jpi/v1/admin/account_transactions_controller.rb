module MnoEnterprise::Concerns::Controllers::Jpi::V1::Admin::AccountTransactionsController
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
  end

  #==================================================================
  # Instance methods
  #==================================================================
  # POST /mnoe/jpi/v1/admin/account_transactions
  def create
    @account_transaction = MnoEnterprise::AccountTransaction.create!(transaction_params)

    render json: @account_transaction.to_json
  end

  protected

  def transaction_params
    params.require(:account_transaction).permit(:currency, :amount_cents, :description, :side).merge!(
      credit_account_id: parent_organization.id
    )
  end

  def parent_organization
    @organization = MnoEnterprise::Organization.find_one(params[:account_transaction][:organization_id])
  end
end
