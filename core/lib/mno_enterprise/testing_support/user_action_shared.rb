module MnoEnterprise

  # Expect user to be defined
  shared_examples 'a navigatable protected user action' do
    context 'with guest user' do
      before { sign_out(user) }
      before { subject }
      it { expect(response).to redirect_to(new_user_session_path) }
    end

    context 'with signed in and unconfirmed user' do
      before { allow_any_instance_of(MnoEnterprise::User).to receive(:confirmed?).and_return(false) }
      before { sign_in user }
      before { subject }
      it { expect(response).to redirect_to(user_confirmation_lounge_path) }
    end

    context 'with signed in and confirmed user' do
      before { sign_in user }
      before { subject }
      it { expect(response.code).to match(/(200|302)/) }
    end
  end

  shared_examples 'a user protected resource' do
    context 'with guest user' do
      before { sign_out(user) }
      before { subject }
      it { expect(response).to redirect_to(new_user_session_path) }
    end

    context 'with authorized user' do
      before { allow(ability).to receive(:can?).with(any_args).and_return(true) }
      before { sign_in user }
      before { subject }
      it { expect(response.code).to match(/20\d|302/) }
    end

    context 'with unauthorized user' do
      before { allow(ability).to receive(:can?).with(any_args).and_return(false) }
      before { sign_in user }
      before { subject }
      it { expect(response.code).to match(/(302|401)/) }
    end
  end

end
