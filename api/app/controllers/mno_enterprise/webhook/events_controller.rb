module MnoEnterprise
  # The object received on this controller looks like  Parameters: {"event"=>"", "object"=>{}, "metadata"={}}
  class Webhook::EventsController < ApplicationController
    include MnoEnterprise::Concerns::Controllers::Webhook::EventsController
    # You can easily overwrite/extend this concern by inserting the code here
  end
end
