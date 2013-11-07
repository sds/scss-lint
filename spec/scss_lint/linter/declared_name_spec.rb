require 'spec_helper'

describe SCSSLint::Linter::DeclaredName do
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
end
