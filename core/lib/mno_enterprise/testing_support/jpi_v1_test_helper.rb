module MnoEnterprise::TestingSupport::JpiV1TestHelper

  # Expect 'user' to be assigned
  shared_examples "jpi v1 protected action" do
    context "with guest user" do
      it "prevents access" do
        sign_out user
        expect(subject).to_not be_successful
        expect(subject.code).to eq('401')
      end
    end

    context 'with signed in user' do
      it "authorizes access" do
        sign_in user
        expect(subject).to be_successful
      end
    end
  end

  # Expect 'user' to be assigned
  # Expect 'ability' to be assigned
  shared_examples "jpi v1 authorizable action" do
    context "with guest user" do
      it "prevents access" do
        sign_out user
        expect(subject).to_not be_successful
        expect(subject.code).to eq('401')
      end
    end

    context 'with unauthorized signed in user' do
      it "prevents access" do
        sign_in user
        allow(ability).to receive(:can?).with(any_args).and_return(false)
        expect(subject).to_not be_successful
      end
    end

    context 'with authorized signed in user' do
      it "authorizes access" do
        sign_in user
        allow(ability).to receive(:can?).with(any_args).and_return(true)
        expect(subject).to be_successful
      end
    end
  end

end
