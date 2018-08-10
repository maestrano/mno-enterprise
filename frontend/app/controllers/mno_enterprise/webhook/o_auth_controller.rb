module MnoEnterprise
  class Webhook::OAuthController < ApplicationController
    include MnoEnterprise::Concerns::Controllers::Webhook::OAuthController
    layout 'mno_enterprise/public', only: [:authorize]
  end
end

