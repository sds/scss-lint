require 'spec_helper'

describe SCSSLint::Linter::DeclaredNameLinter do
  context 'when no variable, functions, or mixin declarations exist' do
    let(:css) { <<-CSS }
      p {
        margin: 0;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a variable name contains a hyphen' do
    let(:css) { <<-CSS }
      $content-padding: 10px;
    CSS

    it { should_not report_lint }
  end

  context 'when a variable name contains an underscore' do
    let(:css) { <<-CSS }
      $content_padding: 10px;
    CSS

    it { should report_lint line: 1 }
  end

  context 'when a variable name contains an uppercase character' do
    let(:css) { <<-CSS }
      $contentPadding: 10px;
    CSS

    it { should report_lint line: 1 }
  end

  context 'when a function is declared with a capital letter' do
    let(:css) { <<-CSS }
      @function badFunction() {
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when a function is declared with an underscore' do
    let(:css) { <<-CSS }
      @function bad_function() {
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when a mixin is declared with a capital letter' do
    let(:css) { <<-CSS }
      @mixin badMixin() {
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when a mixin is declared with an underscore' do
    let(:css) { <<-CSS }
      @mixin bad_mixin() {
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when no placeholder declarations exist' do
    let(:css) { <<-CSS }
      p {
        margin: 0;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a placeholder name contains a hyphen' do
    let(:css) { <<-CSS }
      %placeholder-selector {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a placeholder name contains an underscore' do
    let(:css) { <<-CSS }
      %placeholder_selector {
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when a placeholder name contains an uppercase character' do
    let(:css) { <<-CSS }
      %placeholderSelector {
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when an invalid placeholder name appears in a set of selectors' do
    let(:css) { <<-CSS }
      a,
      %placeholderSelector,
      b {
      }
    CSS

    it { should report_lint line: 3 }
  end

  context 'when an invalid placeholder name has interpolation' do
    let(:css) { <<-CSS }
      %placeholder\#{$value}Selector {
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when a valid placeholder name has interpolation' do
    let(:css) { <<-CSS }
      %placeholder-\#{$value}-selector {
      }
    CSS

    it { should_not report_lint }
  end
end
