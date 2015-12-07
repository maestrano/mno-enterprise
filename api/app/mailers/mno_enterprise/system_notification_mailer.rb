module MnoEnterprise
  class SystemNotificationMailer < ActionMailer::Base
    include MnoEnterprise::Concerns::Mailers::SystemNotificationMailer
  end
end
