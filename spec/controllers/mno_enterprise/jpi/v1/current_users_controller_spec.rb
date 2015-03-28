require 'spec_helper'

module MnoEnterprise
  describe JsApi::V1::CurrentUsersController do
    render_views
    before { request.env["HTTP_ACCEPT"] = 'application/json' }
    
    
    
    describe "GET #show" do
      context "when user is logged in" do
        subject! do
          user = create(:user,free_trial_end_at: Time.now + 1.month)
          sign_in user
          user
        end

        it "should be successful" do
          get :show
          response.should be_success
        end

        it "should assign the current user as @current_user" do
          get :show
          assigns(:user).should == subject
        end

        describe "@deletion_request" do
          it "contains the last active deletion request" do
            deletion_request = create(:deletion_request, deletable:subject)
            get :show
            expect(assigns(:deletion_request)).to eq(deletion_request)
          end

          it "does not contain unactive deletion request" do
            # Create unactive deletion request
            create(:deletion_request, deletable:subject,created_at: Time.now - 1.year)
            get :show
            expect(assigns(:deletion_request)).to eq(nil)
          end
        end

        describe "@organizations" do
          it "calls accessible_by on Organization" do
            Organization.should_receive(:accessible_by).twice.and_call_original
            get :show
          end
        end
      end

      context "when user is not logged in" do
        it "set the new user under free trial" do
          get :show
          assigns(:user).under_free_trial?.should be_true
        end

        it "assigns a new user" do
          get :show
          assigns(:user).should_not be_persisted
        end
      end
    end

  end
end