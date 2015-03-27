partner ||= @partner

json.is_a_partner !!@partner

if @partner
  json.code @partner.code
  json.name @partner.name
  if @partner.reseller_organization
    json.reseller_organization do
      json.id @partner.reseller_organization.id
      json.name @partner.reseller_organization.name
      json.role current_user.role(@partner.reseller_organization)
    end
  end

  # -------------------------------------------------------------------------------------
  # Customer organizations
  # -------------------------------------------------------------------------------------
  json.organizations do
    json.array! @referred_organizations do |organization|
      json.id organization.id
      json.name organization.name
      json.reseller_members do
        json.array! organization.referred_reseller_members do |reseller_member|
          json.id reseller_member.id
          json.name reseller_member.name
          json.surname reseller_member.surname
        end
      end
      if credit_owner = organization.credit_owners.first
        json.credit_owner do
          json.name credit_owner.name
          json.surname credit_owner.surname
        end
      end
      json.current_billing do
        json.amount organization.current_billing({ :take_free_trial_into_account => true }).amount
        json.currency do
          json.iso_code organization.current_billing.currency.iso_code
          json.symbol organization.current_billing.currency.html_entity
        end
      end
      json.name organization.name
      json.app_instances do
        json.array! organization.app_instances do |app_instance|
          json.billing_type app_instance.billing_type
          json.name app_instance.name
          json.status app_instance.status
          json.current_billing do
            json.amount app_instance.current_billing.amount
            json.currency do
              json.iso_code app_instance.current_billing.currency.iso_code
              json.symbol app_instance.current_billing.currency.html_entity
            end
          end
          json.app do
            json.name app_instance.app.name
          end
        end
      end
      json.users do
        json.array! organization.users do |user|
          json.email user.email
          json.name user.name
          json.surname user.surname
          json.last_invoice_date user.last_invoice_date
          json.signup_date user.created_at
          json.role user.role(organization)
        end
      end
    end
  end

  json.webinars do
    json.array! @webinars do |webinar|
      json.id webinar.id
      json.title webinar.title
      json.date webinar.date.strftime("%d %h %Y")
      json.time webinar.date.strftime("%I:%m%P")
    end
  end

  # -------------------------------------------------------------------------------------
  # Statistics (used for the performance monitoring)
  # -------------------------------------------------------------------------------------
  json.referred_signups do
    json.total @partner.referred_signups
    json.last_month @partner.referred_signups(period:Time.now)
    json.progression @partner.referred_signups_progression
  end

  json.referred_paying_customers do
    json.total @partner.referred_signups(paying_customer:true)
    json.last_month @partner.referred_signups(period:Time.now,paying_customer:true)
    json.progression @partner.referred_signups_progression(paying_customer:true)
  end

  json.credits_earned do
    json.total do
      json.amount @partner.credits_earned.amount
      json.currency do
        json.iso_code @partner.credits_earned.currency.iso_code
        json.symbol @partner.credits_earned.currency.html_entity
      end
    end

    json.last_month do
      json.amount @partner.credits_earned(Time.now).amount
      json.currency do
        json.iso_code @partner.credits_earned(Time.now).currency.iso_code
        json.symbol @partner.credits_earned(Time.now).currency.html_entity
      end
    end
    json.progression @partner.credits_earned_progression
  end

  json.sales_to_reach_next_level do
    if hash_sales = @partner.sales_to_reach_next_level
      json.next_level_name hash_sales[:next_level_name]
      json.target do
        json.amount hash_sales[:gross_sales][:target].amount
        json.currency do
          json.iso_code hash_sales[:gross_sales][:target].currency.iso_code
          json.symbol hash_sales[:gross_sales][:target].currency.html_entity
        end
      end
      json.redeemed do
        json.amount hash_sales[:gross_sales][:redeemed].amount
        json.currency do
          json.iso_code hash_sales[:gross_sales][:redeemed].currency.iso_code
          json.symbol hash_sales[:gross_sales][:redeemed].currency.html_entity
        end
      end
      json.togo do
        json.amount hash_sales[:gross_sales][:togo].amount
        json.currency do
          json.iso_code hash_sales[:gross_sales][:togo].currency.iso_code
          json.symbol hash_sales[:gross_sales][:togo].currency.html_entity
        end
      end
    end
  end

  json.current_tier_level @partner.tier_level
  json.how_to_reach_next_level @partner.how_to_reach_next_level


  json.latest_users do
    json.array! @latest_users do |user|
      json.created_at user.created_at.strftime("%d %h %Y")
      json.under_free_trial user.under_free_trial?
      json.name "#{user.name} #{user.surname}"
      json.email user.email
    end
  end

  # -------------------------------------------------------------------------------------
  # Partner Invoices
  # -------------------------------------------------------------------------------------
  json.invoices do
    json.array! @partner.partner_invoices do |invoice|
      json.started_at invoice.started_at.strftime("%d %h %Y")
      json.ended_at invoice.ended_at.strftime("%d %h %Y")
      json.pdf partner_invoice_path(invoice)
      json.total_commission do
        json.amount invoice.total_commission.amount
        json.currency do
          json.iso_code invoice.total_commission.currency.iso_code
          json.symbol invoice.total_commission.currency.html_entity
        end
      end
    end
  end

end
