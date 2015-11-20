# == Schema Information
#
# Endpoint: 
#  - /v1/credit_cards
#  - /v1/organizations/:organization_id/credit_card
#
#  id               :integer         not null, primary key
#  title            :string(255)
#  first_name       :string(255)
#  last_name        :string(255)
#  country          :string(255)
#  masked_number    :string(255)
#  month            :integer
#  year             :integer
#  user_id          :integer
#  token            :string(255)
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#  owner_id         :integer
#  owner_type       :string(255)
#  billing_address  :text
#  billing_city     :string(255)
#  billing_postcode :string(255)
#  billing_country  :string(255)
#  duplicated       :boolean         default(FALSE)
#

module MnoEnterprise
  class CreditCard < BaseResource
    
    attributes :id, :created_at, :updated_at, :title, :first_name, :last_name, :country, :masked_number, :number,
    :month, :year, :billing_address, :billing_city, :billing_postcode, :billing_country, :verification_value, :organization_id
    
    #==============================================================
    # Associations
    #==============================================================
    belongs_to :organization, class_name: 'MnoEnterprise::Organization'
    
  end
end
