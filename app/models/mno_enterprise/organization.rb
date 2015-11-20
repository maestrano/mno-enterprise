# == Schema Information
#
# Endpoint: 
#  - /v1/organizations
#  - /v1/users/:user_id/organizations
#
#  id                       :integer         not null, primary key
#  uid                      :string(255)
#  name                     :string(255)
#  created_at               :datetime        not null
#  updated_at               :datetime        not null
#  account_frozen           :boolean         default(FALSE)
#  free_trial_end_at        :datetime
#  soa_enabled              :boolean         default(TRUE)
#  mails                    :text
#  logo                     :string(255)
#  latitude                 :float           default(0.0)
#  longitude                :float           default(0.0)
#  geo_country_code         :string(255)
#  geo_state_code           :string(255)
#  geo_city                 :string(255)
#  geo_tz                   :string(255)
#  geo_currency             :string(255)
#  meta_data                :text
#  industry                 :string(255)
#  size                     :string(255)
#

module MnoEnterprise
  class Organization < BaseResource
    include MnoEnterprise::Concerns::Models::Organization
  end
end
