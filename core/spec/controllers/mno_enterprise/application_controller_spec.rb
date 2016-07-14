require 'rails_helper'

module MnoEnterprise
  describe ApplicationController, type: :controller do
    # create an anonymous subclass of ApplicationController to expose protected methods
    controller(MnoEnterprise::ApplicationController) do
      def after_sign_in_path_for(resource)
        super
      end
      def add_param_to_fragment(url, param_name, param_value)
        super
      end
    end

    describe '#add_param_to_fragment' do
      it { expect(controller.add_param_to_fragment('/#/platform/accounts', 'foo', 'bar')).to eq('/#/platform/accounts?foo=bar') }
      it { expect(controller.add_param_to_fragment('/', 'foo', 'bar')).to eq('/#?foo=bar') }
      it { expect(controller.add_param_to_fragment('/#/platform/dashboard/he/43?en=690', 'foo', 'bar')).to eq('/#/platform/dashboard/he/43?en=690&foo=bar') }
      it { expect(controller.add_param_to_fragment('/#/platform/dashboard/he/43?en=690', 'foo', [{msg: 'yolo'}])).to eq('/#/platform/dashboard/he/43?en=690&foo=%7B%3Amsg%3D%3E%22yolo%22%7D') }
    end

    describe '#after_sign_in_path_for' do
      before { @request.env["devise.mapping"] = Devise.mappings[:user] }

      it { expect(controller.after_sign_in_path_for(User.new())).to eq('/dashboard/') }
      it { expect(controller.after_sign_in_path_for(User.new(admin_role: "staff"))).to eq('/admin/') }
      it { expect(controller.after_sign_in_path_for(User.new(admin_role: ""))).to eq('/dashboard/') }
      it { expect(controller.after_sign_in_path_for(User.new(admin_role: "admin"))).to eq('/admin/') }
    end
  end
end
