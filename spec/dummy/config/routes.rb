Rails.application.routes.draw do

  mount MnoEnterprise::Engine => "/mnoe", as: :mnoe
end
