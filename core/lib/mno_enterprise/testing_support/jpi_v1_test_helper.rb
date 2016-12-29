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
        expect(subject.code).to eq('403')
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

  shared_examples_for "a not found response" do
    it { expect(subject).to_not be_success }
    it do
      subject
      expect(response.status).to eq(404)
    end
  end

  shared_examples_for "a bad request response" do
    it { expect(subject).to_not be_success }
    it do
      subject
      expect(response.status).to eq(400)
    end
  end

  shared_examples_for "a forbidden response" do
    it { expect(subject).to_not be_success }
    it do
      subject
      expect(response.status).to eq(403)
    end
  end

  shared_examples_for "an internal server error response" do
    it { expect(subject).to_not be_success }
    it do
      subject
      expect(response.status).to eq(500)
    end
  end

  shared_examples_for "a paginated action" do
    it 'adds the pagination metadata' do
      subject
      expect(response.headers['X-Total-Count']).to be_a(Fixnum)
    end
  end
end
