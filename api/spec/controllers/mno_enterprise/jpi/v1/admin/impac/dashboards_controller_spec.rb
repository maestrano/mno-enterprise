require 'rails_helper'

module MnoEnterprise
  describe Jpi::V1::Admin::Impac::DashboardsController, type: :controller do
    include MnoEnterprise::TestingSupport::JpiV1TestHelper
    include MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin
    render_views

    routes { MnoEnterprise::Engine.routes }
    before { request.env["HTTP_ACCEPT"] = 'application/json' }

    let(:user) { build(:user, :admin) }
    before do
      stub_user(user)
      sign_in user

      stub_audit_events
    end

    describe '#index' do
      subject { get :index, params, session_cookies }
      let(:params) { {} }
      let(:session_cookies){ {} }

      context 'when user is a support user' do
        context 'with invalid search params' do
          let(:params) do
            {
              where: {
                name: 'Hello'
              }
            }
          end

          it_behaves_like 'an unauthorized route for support users'
        end

        context 'with an authorized support user search' do
          let(:user) { build(:user, :support) }
          let(:params) do
            {
              where: {
                owner_id: searched_id,
                owner_type: owner_type
              }
            }
          end
          context 'when searching for a user' do
            let(:owner_type) { 'User'}
            let(:searched_id) { "1" }

            it 'authorizes read on the user searched' do
              expect(controller).to receive(:authorize!).with(:read, MnoEnterprise::User.new(id: searched_id))
              subject
            end
          end

          context 'when searching for an org' do
            let(:owner_type) { 'Organization'}
            let(:searched_id) { "1" }

            it 'authorizes read on the user searched' do
              expect(controller).to receive(:authorize!).with(:read, MnoEnterprise::Organization.new(id: searched_id))
              subject
            end
          end
        end
      end
    end
  end
end
