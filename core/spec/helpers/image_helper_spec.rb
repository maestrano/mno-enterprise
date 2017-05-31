require 'rails_helper'

module MnoEnterprise
  describe ImageHelper do
    
    IMAGES_LOCATION = "/app/assets/images/mno_enterprise"

    describe "#main_logo_white_bg_path" do
      it "should return the engine's main-logo filename, when there are no logos"  do
        expect(helper.main_logo_white_bg_path).to eq("mno_enterprise/main-logo.png")
      end
      
      it "should return the engine's main-logo full path when there are no logos"  do
        path = "#{MnoEnterprise::Engine.root}#{IMAGES_LOCATION}/main-logo.png"
        expect(helper.main_logo_white_bg_path(true)).to eq(path)
      end
      
      it "should return the main-logo-whitebg's filename when the file exists"  do
        allow(File).to receive(:exists?).and_return(true)
        expect(helper.main_logo_white_bg_path).to eq("mno_enterprise/main-logo-whitebg.png")
      end

      it "should return the main-logo-whitebg's full path when the file exists"  do
        path = "#{Rails.root}#{IMAGES_LOCATION}/main-logo-whitebg.png"
        allow(File).to receive(:exists?).and_return(true)
        expect(helper.main_logo_white_bg_path(true)).to eq(path)
      end
    end

    describe "#main_logo_path" do
      it "should return the main-logo's path when main-logo exists"  do
        path = "#{Rails.root}#{IMAGES_LOCATION}/main-logo.png"
        allow(File).to receive(:exists?).and_return(true)
        expect(helper.main_logo_path).to eq(path)
      end
      
      it "should return the engine's main-logo path when there are no logos"  do
        path = "#{MnoEnterprise::Engine.root}#{IMAGES_LOCATION}/main-logo.png"
        expect(helper.main_logo_path).to eq(path)
      end
    end
  end
end
