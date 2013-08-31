require 'spec_helper'

describe SCSSLint::Linter::ZeroUnit do
  context 'when no properties exist' do
    let(:css) { <<-CSS }
      p {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when properties with unit-less zeros exist' do
    let(:css) { <<-CSS }
      p {
        margin: 0;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when properties with non-zero values exist' do
    let(:css) { <<-CSS }
      p {
        margin: 5px;
        line-height: 1.5em;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when properties with zero values contain units' do
    let(:css) { <<-CSS }
      p {
        margin: 0px;
      }
    CSS

    it { should report_lint line: 2 }
  end
end
