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

    attributes :owner_id, :title, :message, :send_at, :status, :due_date, :completed_at, :completed_notified_at, :created_at, :updated_at

    # Constant enum of different notification types
    module NOTIFICATION_TYPE
      REMINDER = 'reminder'
      DUE = 'due'
      COMPLETED = 'completed'
    end


    #============================================
    # Scopes
    #============================================
    scope :draft , -> { where(status: 'draft')}
    scope :sent , -> { where(status: 'sent')}
    scope :done , -> { where(status: 'done')}

    scope :to_be_reminded, -> { where('completed_at' => '', 'task_recipients.reminder_date.ne' => '', 'task_recipients.reminder_notified_at' => '', 'task_recipients.reminder_date.lt' => Time.new) }
    scope :due, -> { where( 'due_date.ne' => '', 'completed_at' => '', 'due_date.lt' => Time.new, 'task_recipients.notified_at' => '') }
    scope :completed, -> { where('completed_at.ne' => '', 'completed_notified_at' => '') }
    scope :recipient,  ->(orga_relation_id){ where('task_recipients.orga_relation_id'=> orga_relation_id)}
    scope :owner,  ->(orga_relation_id){ where(owner_id: orga_relation_id)}

    #============================================
    # Associations
    #============================================
    has_many :task_recipients, class_name: 'MnoEnterprise::TaskRecipient'

    #============================================
    # Instance Methods
    #============================================

    # the task was notified for the given orga_relation_id and notification_type
    def notification_received(orga_relation_id, notification_type)
      case notification_type
      when NOTIFICATION_TYPE::COMPLETED
        update(completed_notified_at: Time.new)
      when NOTIFICATION_TYPE::REMINDER
        task_recipient = task_recipient(orga_relation_id)
        task_recipient.update(reminder_notified_at: Time.new)
      when NOTIFICATION_TYPE::DUE
        task_recipient = task_recipient(orga_relation_id)
        task_recipient.update(notified_at: Time.new)
      else
        raise "Invalid notification type: #{notification_type} "
      end
    end

    def task_recipient(orga_relation_id)
      task_recipient = MnoEnterprise::TaskRecipient.where(task_id: id, orga_relation_id: orga_relation_id).first
      raise ActiveRecord::RecordNotFound unless task_recipient
      task_recipient
    end

  end
end
