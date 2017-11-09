require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::NotificationsController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    render_views
    routes { MnoEnterprise::Engine.routes }
    before { request.env['HTTP_ACCEPT'] = 'application/json' }

    before do
      Timecop.freeze(Time.local(1985, 9, 17))
    end

    after do
      Timecop.return
    end

    #===============================================
    # Assignments
    #===============================================
    # Stub controller ability
    let!(:ability) { stub_ability }
    before { allow(ability).to receive(:can?).with(any_args).and_return(true) }

    before { sign_in user }

    # Stub user and user call
    let(:user) { build(:user) }
    let(:organization) { build(:organization) }
    let(:orga_relation) { build(:orga_relation) }

    before do
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      api_stub_for(get: "/orga_relations?#{param_filter(user_id: user.id, organization_id: organization.id)}", response: from_api([orga_relation]))
      api_stub_for(get: "/users/#{user.id}/organizations", response: from_api([organization]))
      sign_in user
    end

    let(:data) { JSON.parse(response.body).deep_symbolize_keys }

    #===============================================
    # Specs
    #===============================================

    describe 'GET #index' do
      let(:to_be_reminded_task) { build(:task, task_recipients: [build(:task_recipient)]) }
      let(:due_task) { build(:task, task_recipients: [build(:task_recipient)]) }
      let(:completed_task) { build(:task, task_recipients: [build(:task_recipient)]) }

      before do
        to_be_reminded_task_params = {
          'status' => 'sent',
          'completed_at' =>  '',
          'task_recipients.orga_relation_id' =>  orga_relation.id,
          'task_recipients.reminder_date.lt' =>  Time.now,
          'task_recipients.reminder_date.ne' =>  '',
          'task_recipients.reminder_notified_at' =>  ''
        }
        api_stub_for(get: "/tasks?#{param_filter(to_be_reminded_task_params)}", response: from_api([to_be_reminded_task]))

        due_task_params = {
          'status' => 'sent',
          'completed_at' => '',
          'due_date.lt' =>  Time.now,
          'due_date.ne' =>  '',
          'task_recipients.notified_at' =>  '',
          'task_recipients.orga_relation_id' =>  orga_relation.id
        }
        api_stub_for(get: "/tasks?#{param_filter(due_task_params)}", response: from_api([due_task]))

        completed_task_params = {
          'status' => 'done',
          'completed_at.ne' => '',
          'completed_notified_at' => '',
          'owner_id' => orga_relation.id,
        }
        api_stub_for(get: "/tasks?#{param_filter(completed_task_params)}", response: from_api([completed_task]))
      end

      subject { get :index, organization_id: organization.id }
      before { subject }
      it { expect(response).to be_success }
      it do
        expected = [
          { object_id: to_be_reminded_task.id, notification_type: 'reminder' },
          { object_id: due_task.id, notification_type: 'due' },
          { object_id: completed_task.id, notification_type: 'completed' }
        ]
        notifications = data[:notifications]
        expect(notifications.length).to be expected.length
        expected.each_with_index { |e, i| expect(notifications[i]).to include(e) }
      end
    end

    describe 'POST #notified' do
      subject { post :notified, organization_id: organization.id, object_type: 'task', object_id: task.id, notification_type: notification_type }
      let(:task) { build(:task) }
      let(:task_recipient) { build(:task_recipient) }

      before do
        api_stub_for(get: "/tasks/#{task.id}", response: from_api(task))
      end
      context 'when notification_type is completed' do
        let(:notification_type) { 'completed' }
        before do
          api_stub_for(put: "/tasks/#{task.id}", response: from_api(task))
        end
        it 'udpates the task completed_notified_at' do
          subject
          expect(response).to be_success
        end
      end
      context 'when notification_type is reminder' do
        let(:notification_type) { 'reminder' }
        before do
          api_stub_for(put: "/task_recipients/#{task_recipient.id}", response: from_api(task_recipient))
          api_stub_for(get: "/task_recipients?#{param_filter(orga_relation_id: orga_relation.id, task_id: task.id)}", response: from_api([task_recipient]))
        end
        it 'udpates the task completed_notified_at' do
          subject
          expect(response).to be_success
        end
      end
      context 'when notification_type is reminder' do
        let(:notification_type) { 'reminder' }
        before do
          api_stub_for(put: "/task_recipients/#{task_recipient.id}", response: from_api(task_recipient))
          api_stub_for(get: "/task_recipients?#{param_filter(orga_relation_id: orga_relation.id, task_id: task.id)}", response: from_api([task_recipient]))

        end
        it 'udpates the task completed_notified_at' do
          subject
          expect(response).to be_success
        end
      end
    end
  end
end

