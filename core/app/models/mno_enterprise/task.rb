# == Schema Information
#
# Endpoint:
#  - api/mnoe/v1/tasks
# owner_id                     integer
# title                        string
# message                      text
# send_at                      datetime
# status                       string
# due_date                     datetime
# completed_at                 datetime
# completed_notified_at        datetime
# mnoe_tenant_id               integer
# created_at                   datetime
# updated_at                   datetime

module MnoEnterprise
  class Task < BaseResource
    
    #============================================
    # Associations
    #============================================
    belongs_to :mnoe_tenant
    has_one :orga_relation, as: :owner, dependent: :destroy
    has_many :task_recipients

  end
end
