MnoEnterprise::Engine.routes.draw do

  # Organization Invites
  resources :org_invites, only: [:show]

end
