# == Schema Information
#
# Endpoint: /v1/apps
#
#  id                       :integer         not null, primary key
#  nid                      :string         e.g.: 'wordpress'
#  name                     :string(255)
#  description              :text
#  created_at               :datetime        not null
#  updated_at               :datetime        not null
#  logo                     :string(255)
#  version                  :string(255)
#  website                  :string(255)
#  slug                     :string(255)
#  categories               :text
#  key_benefits             :text
#  key_features             :text
#  testimonials             :text
#  worldwide_usage          :integer
#  tiny_description         :text
#  popup_description        :text
#  stack                    :string(255)
#  terms_url                :string(255)
#

module MnoEnterprise
  class App < BaseResource
  end
end
