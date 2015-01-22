require 'spec_helper'

describe SCSSLint::Linter::ImportantRule do
  context 'when no !important is used' do
    let(:css) { <<-CSS }
      p {
        color: #000;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when !important is used' do
    let(:css) { <<-CSS }
      p {
        color: #000 !important;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when !important is used in property containing Sass script' do
    let(:css) { <<-CSS }
      p {
        color: \#{$my-var} !important;
      }
    CSS

    it { should report_lint line: 2 }
  end
end
