module MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin
  shared_examples "a jpi v1 admin action" do
    context "without a signed in user" do
      before do
        sign_out('user')
      end

      it "prevents access" do
        expect(subject).to_not be_successful
        expect(subject).to have_http_status(:unauthorized)
      end
    end

    context "with a non admin signed in user" do
      let(:user) { FactoryGirl.build(:user) }
      before do
        stub_user(user)
        sign_in user
      end

      it "prevents access" do
        expect(subject).to_not be_successful
        expect(subject).to have_http_status(:forbidden)
      end
    end

    context "with a signed in admin" do
      let(:user) { FactoryGirl.build(:user, :admin, :with_organizations) }
      before do
        stub_user(user)
        sign_in user
      end

      it "authorizes access" do
        sign_in user
        expect(subject).to be_successful
      end
    end
  end

  shared_examples "an unauthorized route for support users" do
    context "with a signed in admin" do
      let(:user) { FactoryGirl.build(:user, :support, :with_organizations) }
      before do
        stub_user(user)
        sign_in user
      end

      it "prevents access" do
        expect(subject).to_not be_successful
        expect(subject).to have_http_status(:forbidden)
      end
    end
  end

  shared_examples "an authorized #organization_id route for support users" do
    subject { get controller_action, params, session}
    let(:user) { FactoryGirl.build(:user, :support, :with_organizations) }
    let(:orgId) { organization.id }
    let(:organization_authorized) {  MnoEnterprise::Organization.new(id: orgId) }
    let(:params) { { organization_id: orgId, id: entity&.id }.compact }
    let(:session) { { support_org_id: orgId } }

    before do
      stub_user(user)
      sign_in user
    end

    it 'calls authorize on the organization' do
      expect(controller).to receive(:authorize!).with(:read, organization_authorized)
      subject
    end
  end

  shared_examples "an authorized route for support users" do
    context "with a signed in admin" do
      let(:user) { FactoryGirl.build(:user, :support, :with_organizations) }
      before do
        stub_user(user)
        sign_in user
      end

      it "authorizes access" do
        sign_in user
        expect(subject).to be_successful
      end
    end
  end
end
