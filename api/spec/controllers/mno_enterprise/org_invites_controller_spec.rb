require 'rails_helper'

def mnoe_home_path
  controller.send(:mnoe_home_path)
end

module MnoEnterprise
  describe OrgInvitesController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }

    let(:user) { build(:user) }
    let(:invite) { build(:orga_invite, user: user) }
    let(:token) { invite.token }

    before do
      stub_user(user)
      # Invite stubs
      stub_api_v2(:put, "/orga_invites/#{invite.id}", invite)
    end

    let!(:orga_invites_stub){  stub_api_v2(:get, '/orga_invites', [invite], %i(user organization), {filter:{id: invite.id, status: 'pending', token: token}, page:{number: 1, size: 1}})}

    describe 'GET #show' do
      subject { get :show, id: invite.id, token: token}

      let(:success_fragment) { "#!?dhbRefId=#{invite.organization.id}&#{URI.encode_www_form([['flash', {msg: "You are now part of #{invite.organization.name}", type: :success}.to_json]])}" }
      let(:expired_fragment) { "#!?#{URI.encode_www_form([['flash', {msg: "It looks like this invite has expired. Please ask your company administrator to resend the invite.", type: :error}.to_json]])}" }
      let(:invalid_fragment) { "#!?#{URI.encode_www_form([['flash', {msg: "Unfortunately, this invite does not seem to be valid.", type: :error}.to_json]])}" }

      context 'when not signed in' do
        it { expect(subject).not_to be_success }
        it { expect(subject).to redirect_to(new_user_session_path) }
      end

      context 'when signed in' do
        before { sign_in user }
        before{ stub_api_v2(:patch, "/orga_invites/#{invite.id}/accept")}
        before { subject }
        it { expect(response).to redirect_to(mnoe_home_path + success_fragment) }
        # TODO: Check that the rendering is the same
        # it { expect(assigns(:org_invite)).to eq(invite) }

        context 'with expired invited' do
          let(:invite) { build(:orga_invite, :expired, user: user) }
          it { expect(response).to redirect_to(mnoe_home_path + expired_fragment) }
        end

        context 'without token' do
          let(:token) { nil }
          it { expect(response).to redirect_to(mnoe_home_path + invalid_fragment) }
        end
      end
    end
  end
end
