Rails.application.routes.draw do

  mount MnoEnterprise::Engine => "/mnoe", as: :mno_enterprise
end
