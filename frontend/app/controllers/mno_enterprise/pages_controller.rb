module MnoEnterprise
  class PagesController < ApplicationController
    # mno-enterprise/api concern
    include MnoEnterprise::Concerns::Controllers::PagesController

    # mno-enterprise/frontend concern
    include MnoEnterprise::Frontend::Concerns::Controllers::PagesController
  end
end
