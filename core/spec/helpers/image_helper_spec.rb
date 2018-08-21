require 'rails_helper'

module MnoEnterprise
  describe ImageHelper do

    let(:folder) { '/app/assets/images/mno_enterprise' }
    let(:root) {"#{Rails.root}#{folder}"}
    let(:path_engine_main_logo) { "#{MnoEnterprise::Engine.root}#{folder}/main-logo.png" }
    let(:path_main_logo) { "#{root}/main-logo.png" }
    let(:path_main_logo_white) { "#{root}/main-logo-whitebg.png" }

    describe '#main_logo_white_bg_path' do
      context 'when no logos exist' do

        it 'returns the engine main-logo filename' do
          expect(helper.main_logo_white_bg_path).to match('mno_enterprise/main-logo.png')
        end

        it 'returns the engine main-logo full path' do
          expect(helper.main_logo_white_bg_path(true)).to match(path_engine_main_logo)
        end
      end

      context 'when main-logo.png exists and main-logo-whitebg.png do not exist' do
        before { allow(File).to receive(:exists?).with(path_main_logo_white).and_return(false) }
        before { allow(File).to receive(:exists?).with(path_main_logo).and_return(true) }

        it 'returns the main-logo filename' do
          expect(helper.main_logo_white_bg_path).to match('mno_enterprise/main-logo.png')
        end

        it 'returns the main-logo full path' do
          expect(helper.main_logo_white_bg_path(true)).to match(path_main_logo)
        end
      end

      context 'when main-logo-whitebg.png exists' do
        before { allow(File).to receive(:exists?).with(path_main_logo_white).and_return(true) }

        it 'returns the filename' do
          expect(helper.main_logo_white_bg_path).to match('mno_enterprise/main-logo-whitebg.png')
        end

        it 'returns the full path' do
          expect(helper.main_logo_white_bg_path(true)).to match(path_main_logo_white)
        end
      end
    end

    describe '#main_logo_path' do

      context 'when there are no logos' do

        it 'returns the engines main-logo' do
          expect(helper.main_logo_path).to match(path_engine_main_logo)
        end
      end

      context 'when main-logo.png exists' do
        before { allow(File).to receive(:exists?).with(path_main_logo).and_return(true) }

        it 'returns the full path' do
          expect(helper.main_logo_path).to match(path_main_logo)
        end
      end
    end

    describe '#fit_image' do

      it 'returns the style' do
        expect(helper.fit_image).to match('max-width: 150px; max-height: 150px;')
      end
    end

    describe '#main_logo_white_bg_size_to_fit' do
      let(:original_dimensions) { [300, 300]}
      before { allow(helper).to receive(:main_logo_white_bg_dimensions) { original_dimensions } }

      context 'when both dimensions are bigger than 150x150' do
        it 'returns the dimensions to fit' do
          expect(helper.main_logo_white_bg_size_to_fit).to eq({ width: 150, height: 150 })
        end
      end

      context 'when both dimensions are smaller than 150x150' do
        let(:original_dimensions) { [120, 75] }
        it "doesn't modify the dimensions" do
          expect(helper.main_logo_white_bg_size_to_fit).to eq({ width: 120, height: 75 })
        end
      end

      context 'when the width is bigger' do
        let(:original_dimensions) { [170, 75] }
        it "returns the dimensions to fit" do
          expect(helper.main_logo_white_bg_size_to_fit).to eq({ width: 150, height: 75 * 150 / 170 })
        end
      end

      context 'when the height is bigger' do
        let(:original_dimensions) { [40, 200] }
        it "returns the dimensions to fit" do
          expect(helper.main_logo_white_bg_size_to_fit).to eq({ width: 40 * 150 / 200, height: 150 })
        end
      end
    end
  end
end
