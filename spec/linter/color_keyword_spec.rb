require 'spec_helper'

describe SCSSLint::Linter::ColorKeyword do
  context 'when a color is specified as a hex' do
    let(:css) { <<-CSS }
      p {
        color: #fff;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a color is specified as a keyword' do
    let(:css) { <<-CSS }
      p {
        color: white;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a property contains a color keyword as a string' do
    let(:css) { <<-CSS }
      p {
        content: 'white';
      }
    CSS

    it { should_not report_lint }
  end
end
