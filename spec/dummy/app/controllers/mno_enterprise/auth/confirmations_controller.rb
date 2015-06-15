module MnoEnterprise
  class Auth::ConfirmationsController < Devise::ConfirmationsController
    include MnoEnterprise::Concerns::Controllers::Auth::ConfirmationsController
    
    def finalize
      puts "I AM STARTING THE FINALIZE ACTION"
      super do |event,resource|
        case event
        when :success
          puts "USER HAS BEEN CONFIRMED SUCCESSFULLY"
        when :already_confirmed
          puts "HMM NO NEED TO CONFIRM THIS USER"
        when :error
          puts "OooPs - THERE SEEM TO BE SOME ERRORS!"
        end
      end
      puts "I HAVE FINISHED THE FINALIZE ACTION"
    end
  end
end