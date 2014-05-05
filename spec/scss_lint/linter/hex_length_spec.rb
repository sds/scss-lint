require 'spec_helper'

describe SCSSLint::Linter::HexLength do
  let(:linter_config) { { 'style' => style } }
  let(:style) { 'short' }

  context 'when rule is empty' do
    let(:css) { <<-CSS }
      p {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule contains properties with valid hex code' do
    let(:css) { <<-CSS }
      p {
        color: #1234ab;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when ID selector starts with a hex code' do
    let(:css) { <<-CSS }
      #aabbcc {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when color is specified as a color keyword' do
    let(:css) { <<-CSS }
      p {
        @include box-shadow(0 0 1px 1px gold);
      }
    CSS

    it { should_not report_lint }
  end

  context 'short stlye' do
    let(:style) { 'short' }

    context 'with short hex code' do
      let(:css) { <<-CSS }
        p {
          background: #ccc;
          background: #CCC;
          @include crazy-color(#fff);
        }
      CSS

      it { should_not report_lint }
    end

    context 'with long hex code that could be condensed to 3 digits' do
      let(:css) { <<-CSS }
        p {
          background: #cccccc;
          background: #CCCCCC;
          @include crazy-color(#ffffff);
        }
      CSS

      it { should report_lint line: 2 }
      it { should report_lint line: 3 }
      it { should report_lint line: 4 }
    end
  end

  context 'long style' do
    let(:style) { 'long' }

    context 'with long hex code that could be condensed to 3 digits' do
      let(:css) { <<-CSS }
        p {
          background: #cccccc;
          background: #CCCCCC;
          @include crazy-color(#ffffff);
        }
      CSS

      it { should_not report_lint }
    end

    context 'with short hex code' do
      let(:css) { <<-CSS }
        p {
          background: #ccc;
          background: #CCC;
          @include crazy-color(#fff);
        }
      CSS

      it { should report_lint line: 2 }
      it { should report_lint line: 3 }
      it { should report_lint line: 4 }
    end
  end
end
