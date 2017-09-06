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

    attributes :role, :orga_relation_id, :read_at, :notified_at, :reminder_date, :reminder_notified_at, :user, :organization

    #==============================================================
    # Associations
    #==============================================================
    belongs_to :task, class_name: 'MnoEnterprise::Task'
  end
end
