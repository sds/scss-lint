require 'spec_helper'

describe SCSSLint::Linter::ColorVariable do
  context 'when a color literal is used in a variable declaration' do
    let(:scss) { <<-SCSS }
      $my-color: #f00;
    SCSS

    it { should_not report_lint }
  end

  context 'when a color literal is used in a property' do
    let(:scss) { <<-SCSS }
      p {
        color: #f00;
      }
    SCSS

    it { should report_lint line: 2 }
  end

  context 'when a color literal is used in a function call' do
    let(:scss) { <<-SCSS }
      p {
        color: my-func(#f00);
      }
    SCSS

    it { should report_lint line: 2 }
  end

  context 'when a color literal is used in a mixin' do
    let(:scss) { <<-SCSS }
      p {
        @include my-mixin(#f00);
      }
    SCSS

    it { should report_lint line: 2 }
  end

  context 'when a color literal is used in a shorthand property' do
    let(:scss) { <<-SCSS }
      p {
        border: 1px solid #f00;
      }
    SCSS

    it { should report_lint line: 2 }
  end

  context 'when a number is used in a property' do
    let(:scss) { <<-SCSS }
      p {
        z-index: 9000;
        transition-duration: 250ms;
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when a non-color keyword is used in a property' do
    let(:scss) { <<-SCSS }
      p {
        overflow: hidden;
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when a variable is used in a property' do
    let(:scss) { <<-SCSS }
      p {
        color: $my-color;
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when a variable is used in a function call' do
    let(:scss) { <<-SCSS }
      p {
        color: my-func($my-color);
      }
    SCSS

    it { should_not report_lint }
  end

  context 'when a variable is used in a shorthand property' do
    let(:scss) { <<-SCSS }
      p {
        border: 1px solid $my-color;
      }
    SCSS

    it { should_not report_lint }
  end
end
