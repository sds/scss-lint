require 'spec_helper'

describe SCSSLint::Linter::ColorVariable do
  context 'when a color literal is used in a variable declaration' do
    let(:css) { <<-CSS }
      $my-color: #f00;
    CSS

    it { should_not report_lint }
  end

  context 'when a color literal is used in a property' do
    let(:css) { <<-CSS }
      p {
        color: #f00;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a color literal is used in a function call' do
    let(:css) { <<-CSS }
      p {
        color: my-func(#f00);
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a color literal is used in a mixin' do
    let(:css) { <<-CSS }
      p {
        @include my-mixin(#f00);
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a color literal is used in a shorthand property' do
    let(:css) { <<-CSS }
      p {
        border: 1px solid #f00;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a number is used in a property' do
    let(:css) { <<-CSS }
      p {
        z-index: 9000;
        transition-duration: 250ms;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a non-color keyword is used in a property' do
    let(:css) { <<-CSS }
      p {
        overflow: hidden;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a variable is used in a property' do
    let(:css) { <<-CSS }
      p {
        color: $my-color;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a variable is used in a function call' do
    let(:css) { <<-CSS }
      p {
        color: my-func($my-color);
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a variable is used in a shorthand property' do
    let(:css) { <<-CSS }
      p {
        border: 1px solid $my-color;
      }
    CSS

    it { should_not report_lint }
  end
end
