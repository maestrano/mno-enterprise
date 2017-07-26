# == Schema Information
#
# Endpoint:
#  - api/mnoe/v1/task/1/recipients
# task_id               integer
# orga_relation_id      integer
# read_at               datetime
# notified_at           datetime
# reminder_date         datetime
# reminder_notified_at  datetime
# mnoe_tenant_id        integer
# created_at            datetime
# updated_at            datetime

module MnoEnterprise
  class TaskRecipient < BaseResource
    
    #==============================================================
    # Associations
    #==============================================================
    belongs_to :mnoe_tenant
    belongs_to :orga_relation
    belongs_to :task
  end
end
