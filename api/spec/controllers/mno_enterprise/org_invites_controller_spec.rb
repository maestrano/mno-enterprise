require 'rails_helper'

def mnoe_home_path
  controller.send(:mnoe_home_path)
end

module MnoEnterprise
  describe OrgInvitesController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }

    let(:user) { build(:user) }
    let(:invite) { build(:org_invite, user: user) }
    let(:token) { invite.token }

    before do
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))

      # Invite stubs
      api_stub_for(get: "/org_invites?filter[id]=#{invite.id}&filter[status]=pending&filter[token]=#{token}", response: from_api([invite]))
      api_stub_for(get: "/org_invites?filter[id]=#{invite.id}&filter[status]=pending&filter[token]", response: from_api([]))
      api_stub_for(put: "/org_invites/#{invite.id}", response: from_api(invite.tap { |x| x.status = 'accepted' }))
    end

    describe "GET #show" do
      subject { get :show, id: invite.id, token: token}

      let(:success_fragment) { "#?dhbRefId=#{invite.organization.id}&#{URI.encode_www_form([['flash', {msg: "You are now part of #{invite.organization.name}", type: :success}.to_json]])}" }
      let(:expired_fragment) { "#?#{URI.encode_www_form([['flash', {msg: "It looks like this invite has expired. Please ask your company administrator to resend the invite.", type: :error}.to_json]])}" }
      let(:invalid_fragment) { "#?#{URI.encode_www_form([['flash', {msg: "Unfortunately, this invite does not seem to be valid.", type: :error}.to_json]])}" }

      context 'when not signed in' do
        it { expect(subject).not_to be_success }
        it { expect(subject).to redirect_to(new_user_session_path) }
      end

      context 'when signed in' do
        before { sign_in user }
        before { subject }

        it { expect(response).to redirect_to(mnoe_home_path + success_fragment) }
        it { expect(assigns(:org_invite)).to eq(invite) }

        context 'with expired invited' do
          let(:invite) { build(:org_invite, :expired, user: user) }
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
