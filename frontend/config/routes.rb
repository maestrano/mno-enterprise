MnoEnterprise::Engine.routes.draw do

  #============================================================
  # Static Pages
  #============================================================
  root to: redirect { MnoEnterprise.router.dashboard_path }
end
