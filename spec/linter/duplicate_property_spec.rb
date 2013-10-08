require 'spec_helper'

describe SCSSLint::Linter::DuplicateProperty do
  context 'when rule set is empty' do
    let(:css) { <<-CSS }
      p {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule set contains no duplicates' do
    let(:css) { <<-CSS }
      p {
        margin: 0;
        padding: 0;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule set contains duplicates' do
    let(:css) { <<-CSS }
      p {
        margin: 0;
        padding: 0;
        margin: 1em;
      }
    CSS

    it { should report_lint line: 4 }
  end

  context 'when rule set contains multiple duplicates' do
    let(:css) { <<-CSS }
      p {
        margin: 0;
        padding: 0;
        margin: 1em;
        margin: 2em;
      }
    CSS

    it { should report_lint line: 4 }
    it { should report_lint line: 5 }
  end

  context 'when rule set contains duplicate properties with interpolation' do
    let(:css) { <<-CSS }
      p {
        $direction: 'right';
        margin-\#{direction}: 0;
        $direction: 'left';
        margin-\#{direction}: 0;
      }
    CSS

    it { should_not report_lint }
  end
end
