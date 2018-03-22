require 'rails_helper'

describe HtmlProcessor do
  describe '#initialize' do
    context 'with markdown' do
      let(:input) { "## Hello" }

      it 'sanitizes the input' do
        expect(HtmlProcessor.new(input, format: :markdown).html).to eql("<h2>Hello</h2>\n")
      end

      context 'with embedded video' do
        let(:input) { '<img class="ta-insert-video" ta-insert-video="http://www.youtube.com/embed/XOhZgAPn_CU" src="" allowfullscreen="true" width="521" frameborder="0" height="293"/>' }

        it 'sanitizes the input' do
          expect(HtmlProcessor.new(input, format: :markdown).html).to eql("<p><img class=\"ta-insert-video\" ta-insert-video=\"http://www.youtube.com/embed/XOhZgAPn_CU\" src allowfullscreen=\"true\" frameborder=\"0\"></p>\n")
        end
      end
    end
  end
end
