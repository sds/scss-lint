require 'spec_helper'

describe SCSSLint::Linter::HexNotation do
  let(:linter_config) { { 'style' => style } }
  let(:style) { nil }

  context 'when rule is empty' do
    let(:css) { <<-CSS }
      p {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule contains color keyword' do
    let(:css) { <<-CSS }
      p {
        border-color: red;
      }
    CSS

    it { should_not report_lint }
  end

  context 'lowercase style' do
    let(:style) { 'lowercase' }

    context 'when rule contains properties with lowercase hex code' do
      let(:css) { <<-CSS }
        p {
          background: #ccc;
          color: #cccccc;
          @include crazy-color(#fff);
        }
      CSS

      it { should_not report_lint }
    end

    context 'with uppercase hex codes' do
      let(:css) { <<-CSS }
        p {
          background: #CCC;
          color: #CCCCCC;
          @include crazy-color(#FFF);
        }
      CSS

      it { should report_lint line: 2 }
      it { should report_lint line: 3 }
      it { should report_lint line: 4 }
    end
  end

  context 'uppercase style' do
    let(:style) { 'uppercase' }

    context 'with uppercase hex codes' do
      let(:css) { <<-CSS }
        p {
          background: #CCC;
          color: #CCCCCC;
          @include crazy-color(#FFF);
        }
      CSS

      it { should_not report_lint }
    end

    context 'when rule contains properties with lowercase hex code' do
      let(:css) { <<-CSS }
        p {
          background: #ccc;
          color: #cccccc;
          @include crazy-color(#fff);
        }
      CSS

      it { should report_lint line: 2 }
      it { should report_lint line: 3 }
      it { should report_lint line: 4 }
    end
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
end
