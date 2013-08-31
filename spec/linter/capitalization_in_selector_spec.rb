require 'spec_helper'

describe SCSSLint::Linter::CapitalizationInSelector do
  context 'when selector is all lowercase' do
    let(:css) { <<-CSS }
      span {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when selector is lowercase with non-alphabetic characters' do
    let(:css) { <<-CSS }
      .foo-bar {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when selector is camelCase' do
    let(:css) { <<-CSS }
      .fooBar {
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when selector is UPPER CASE' do
    let(:css) { <<-CSS }
      SPAN {
      }
    CSS

    it { should report_lint line: 1 }
  end
end
