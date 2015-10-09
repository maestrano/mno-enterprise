json.item @item

json.cart do
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
end

