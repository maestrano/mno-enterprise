module MnoEnterprise::TestingSupport::SharedExamples::JpiV1Admin
  shared_examples "a jpi v1 admin action" do
    context "without a signed in user" do
      before { sign_out('user') }

      it "prevents access" do
        expect(subject).to_not be_successful
        expect(subject.code).to eq('401')
      end
    end

    context "with a non admin signed in user" do
      let(:user) { FactoryGirl.build(:user) }
      before do
        stub_api_v2(:get, "/users/#{user.id}", user)
        sign_in user
      end

      it "prevents access" do
        expect(subject).to_not be_successful
        expect(subject.code).to eq('401')
      end
    end

    context "with a signed in admin" do
      let(:user) { FactoryGirl.build(:user, :admin, :with_organizations) }
      before do
        stub_api_v2(:get, "/users/#{user.id}", user)
        sign_in user
      end

      it "authorizes access" do
        sign_in user
        expect(subject).to be_successful
      end
    end
  end
end
