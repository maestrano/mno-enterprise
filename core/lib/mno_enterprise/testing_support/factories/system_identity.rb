# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :system_identity, class: MnoEnterprise::SystemIdentity do
    sequence(:id, &:to_s)
    sequence(:name) { |n| "Environment #{n}" }
    description 'Environment details'

    status 'active'
    idp_certificate nil
    idp_certificate_fingerprint nil
    preferred_locale 'en-GB'

    mnohub_endpoint 'https://api-hub.example.com'
    connec_endpoint 'https://api-connec.example.com'
    impac_endpoint 'https://api-impac.example.com'
    nex_endpoint 'https://api-nex.example.com'
  end
end
