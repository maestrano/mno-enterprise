json.id @cart.id
json.pdfUrl @cart.read_attribute(:pdf) ? cart_invoice_url(@cart.slug) : nil

json.content do
  json.appInstances (@cart.content[:app_instances] || {}).values
  json.services (@cart.content[:services] || {}).values
  json.support @cart.content[:support]
  json.deal @cart.content[:deal]
end

json.total do
  json.monthly @cart.total_monthly
  json.monthlyRaw @cart.total_monthly_raw
  
  json.hourly @cart.total_hourly
  json.adhoc @cart.total_adhoc
  
  json.upfrontWithTax @cart.total_upfront_with_tax
  json.upfrontTax @cart.total_upfront_tax
  
  json.upfront @cart.total_upfront
  json.upfrontBeforeCredit @cart.total_upfront_before_credit
  json.upfrontRaw @cart.total_upfront_raw
  
  json.upfrontSavings @cart.total_upfront_savings
  json.supportCredit @cart.total_support_credit
end

json.orderList @cart.order_list

json.setting do
  json.prepayMonths @cart.prepay_months
  json.reductionPercent @cart.reduction_whole_percent
  json.underFreeTrial @cart.under_free_trial?
  json.freeTrialEligible @cart.free_trial_eligible?
  json.creditCardRequired @cart.credit_card_required?
  json.monthlyCreditAvailable @cart.monthly_credit_available?
  json.ownedSupportPlan @cart.owned_support_plan
end

json.creditCard do
  if @cart.credit_card
    cc = @cart.credit_card
    
    json.id cc.id
    json.title cc.title
    json.first_name cc.first_name
    json.last_name cc.last_name
    json.number cc.masked_number
    json.month cc.month
    json.year cc.year
    json.country cc.country
    
    json.billing_address cc.billing_address
    json.billing_city cc.billing_city
    json.billing_postcode cc.billing_postcode
    json.billing_country cc.billing_country
  end
end