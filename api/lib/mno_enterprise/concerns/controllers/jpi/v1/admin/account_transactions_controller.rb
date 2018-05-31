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
    authorize! :create_account_transaction, MnoEnterprise::Tenant.show

    @account_transaction = MnoEnterprise::AccountTransaction.create!(transaction_params)

    MnoEnterprise::EventLogger.info('account_transaction_created', current_user.id, 'AccountTransaction created', @account_transaction)
    render json: @account_transaction.to_json
  end

  protected

  def transaction_params
    params.require(:account_transaction).permit(:currency, :amount_cents, :description, :side).merge!(
      credit_account_id: parent_organization.credit_account_id
    )
  end

  def parent_organization
    @organization = MnoEnterprise::Organization.find_one(params[:account_transaction][:organization_id])
  end
end
