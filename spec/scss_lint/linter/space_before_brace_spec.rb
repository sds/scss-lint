require 'spec_helper'

describe SCSSLint::Linter::SpaceBeforeBrace do
  context 'when opening brace is preceded by a space' do
    let(:css) { <<-CSS }
      p {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when opening brace is preceded by more than one space' do
    let(:css) { <<-CSS }
      p  {
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when opening brace is not preceded by a space' do
    let(:css) { <<-CSS }
      p{
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when curly brace appears in a string' do
    let(:css) { <<-CSS }
      a {
        content: "{";
      }
    CSS

    it { should_not report_lint }
  end
end
