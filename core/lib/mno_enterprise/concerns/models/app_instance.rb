# == Schema Information
#
# Endpoint:
#  - /v1/app_instances
#  - /v1/organizations/:organization_id/app_instances
#
#  id                   :integer         not null, primary key
#  uid                  :string(255)
#  name                 :string(255)
#  status               :string(255)
#  app_id               :integer
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  started_at           :datetime
#  stack                :string(255)
#  owner_id             :integer
#  owner_type           :string(255)
#  terminated_at        :datetime
#  stopped_at           :datetime
#  billing_type         :string(255)
#  autostop_at          :datetime
#  autostop_interval    :integer
#  next_status          :string(255)
#  soa_enabled          :boolean         default(FALSE)
#
# ===> to be confirmed
#  http_url
#  durations                :text
#  microsoft_licence_id :integer
#

module MnoEnterprise::Concerns::Models::AppInstance
  extend ActiveSupport::Concern

  #==================================================================
  # Included methods
  #==================================================================
  # 'included do' causes the included code to be evaluated in the
  # context where it is included rather than being executed in the module's context
  included do
    attributes :id, :uid, :name, :status, :app_id, :created_at, :updated_at, :started_at, :stack, :owner_id,
    :owner_type, :terminated_at, :stopped_at, :billing_type, :autostop_at, :autostop_interval,
    :next_status, :soa_enabled, :oauth_company, :oauth_keys, :oauth_keys_valid, :free_trial_end_at, :per_user_licence, :active_licences_count

    #==============================================================
    # Constants
    #==============================================================
    ACTIVE_STATUSES = [:running, :stopped, :staged, :provisioning, :starting, :stopping, :updating]
    TERMINATION_STATUSES = [:terminating, :terminated]

    #==============================================================
    # Associations
    #==============================================================
    belongs_to :owner, class_name: 'MnoEnterprise::Organization'
    belongs_to :app, class_name: 'MnoEnterprise::App'

    # Define connector_stack?, cloud_stack? etc. methods
    [:cube, :cloud, :connector].each do |stackname|
      define_method("#{stackname}_stack?") do
        self.stack == stackname.to_s
      end
    end

    scope :active, -> { where('status.in' => ACTIVE_STATUSES) }
  end

  #==================================================================
  # Class methods
  #==================================================================
  module ClassMethods
    # def some_class_method
    #   'some text'
    # end
  end

  #==================================================================
  # Instance methods
  #==================================================================
  # Send a request to terminate the AppInstance
  # Alias of destroy
  # TODO: specs
  def terminate
    self.destroy
  end

  # Return true if the instance can be considered active
  # Route53 DNS propagation may take up to a minute, so we force a minimum of 60 seconds before considering the application online
  def active?
    ACTIVE_STATUSES.include?(self.status.to_sym)
  end

  def per_user_licence?
    self.per_user_licence
  end

  def under_free_trial?
    self.under_free_trial
  end

  def running?
    self.status == 'running'
  end

  def to_audit_event
    {
      id: id,
      uid: uid,
      name: name,
      app_nid: app ? app.nid : nil
    }
  end


end
