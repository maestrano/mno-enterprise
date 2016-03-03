require 'rails_helper'

# TODO: DRY Specs with shared examples
module MnoEnterprise
  describe DeletionRequestsController, type: :controller do
    render_views
    routes { MnoEnterprise::Engine.routes }

    # Stub controller ability
    let!(:ability) { stub_ability }
    before { allow(ability).to receive(:can?).with(any_args).and_return(true) }

    # Stub model calls
    let(:deletion_req) { build(:deletion_request) }
    let(:user) { build(:user, deletion_request: deletion_req) }

    before do
      api_stub_for(get: "/users/#{user.id}", response: from_api(user))
      api_stub_for(get: "/users/#{user.id}/deletion_request", response: from_api(user))
    end

    describe "GET #show'" do
      before { sign_in user }
      subject { get :show, id: deletion_req.token }

      # TODO: use behavior
      it_behaves_like "a navigatable protected user action"
      # it_behaves_like "a user protected resource"

      context 'when no current_request' do
        let(:user) { build(:user, deletion_request: nil) }

        it 'redirects to the root_path' do
          subject
          expect(response).to redirect_to(main_app.root_path)
        end
      end

      context 'when not the current request' do
        let(:new_deletion_req) { build(:deletion_request) }
        let(:user) { build(:user, deletion_request: new_deletion_req) }

        it 'redirects to the root_path' do
          subject
          expect(response).to redirect_to(main_app.root_path)
        end
      end
    end

    describe "PUT #freeze_account" do
      # before { api_stub_for(get: "/deletion_requests/#{deletion_req.id}", response: from_api(deletion_req)) }
      before { api_stub_for(put: "/deletion_requests/#{deletion_req.id}", response: from_api(deletion_req)) }

      before { sign_in user }
      subject { put :freeze_account, id: deletion_req.token }

      # TODO: use behavior
      it_behaves_like "a navigatable protected user action"

      context 'when the request is pending' do
        it 'freezes the account' do
          expect(controller.current_user).to receive(:deletion_request).and_return(deletion_req)
          expect(deletion_req).to receive(:freeze_account!)
          subject
        end

        it 'redirects to the deletion request' do
          subject
          expect(response).to redirect_to(deletion_request_url(deletion_req))
        end
      end

      context 'when the request is not pending' do
        let(:deletion_req) { build(:deletion_request, status: 'account_frozen') }

        it 'does not freezes the account' do
          expect_any_instance_of(MnoEnterprise::DeletionRequest).not_to receive(:freeze_account!)
          subject
        end

        it 'redirects to the deletion request' do
          subject
          expect(response).to redirect_to(deletion_request_url(deletion_req))
        end

        it 'displays an error message' do
          subject
          expect(flash[:alert]).to eq("Invalid action")
        end
      end

      context 'when no valid request' do
        let(:user) { build(:user, deletion_request: nil) }
        it 'redirects to the root_path' do
          subject
          expect(response).to redirect_to(main_app.root_path)
        end
      end

    end

    describe "PUT #checkout" do
      before { api_stub_for(put: "/deletion_requests/#{deletion_req.id}", response: from_api(deletion_req)) }

      before { sign_in user }
      subject { put :checkout, id: deletion_req.token }

      # TODO: use behavior
      it_behaves_like "a navigatable protected user action"

      context 'when the request is not account_frozen' do
        let(:deletion_req) { build(:deletion_request, status: 'pending') }

        # it 'does not freezes the account' do
        #   expect_any_instance_of(MnoEnterprise::DeletionRequest).not_to receive(:freeze_account!)
        #   subject
        # end

        it 'redirects to the deletion request' do
          subject
          expect(response).to redirect_to(deletion_request_url(deletion_req))
        end

        it 'displays an error message' do
          subject
          expect(flash[:alert]).to eq("Invalid action")
        end
      end

      context 'when no valid request' do
        let(:user) { build(:user, deletion_request: nil) }
        it 'redirects to the root_path' do
          subject
          expect(response).to redirect_to(main_app.root_path)
        end
      end
    end

    describe "PUT #terminate"
  end
end
