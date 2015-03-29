module MnoEnterprise
  class PagesController < ApplicationController
    before_filter :authenticate_user!, :only => [:myspace]
    
    # GET /myspace
    def myspace
      # Meta Information
      @meta[:title] = "Dashboard"
      @meta[:description] = "Dashboard"
      render layout: 'mno_enterprise/application_dashboard'
    end
  end
end