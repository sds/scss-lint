require 'spec_helper'

describe SCSSLint::Linter::UnnecessaryMantissa do
  context 'when value is zero' do
    let(:css) { <<-CSS }
      p {
        margin: 0;
        padding: func(0);
        top: 0em;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when value contains no mantissa' do
    let(:css) { <<-CSS }
      p {
        margin: 1;
        padding: func(1);
        top: 1em;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when value contains a mantissa with a zero' do
    let(:css) { <<-CSS }
      p {
        margin: 1.0;
        padding: func(1.0);
        top: 1.0em;
      }
    CSS

    it { should report_lint line: 2 }
    it { should report_lint line: 3 }
    it { should report_lint line: 4 }
  end

  context 'when value contains a mantissa with multiple zeroes' do
    let(:css) { <<-CSS }
      p {
        margin: 1.000;
        padding: func(1.000);
        top: 1.000em;
      }
    CSS

    it { should report_lint line: 2 }
    it { should report_lint line: 3 }
    it { should report_lint line: 4 }
  end

  context 'when value contains a mantissa with multiple zeroes followed by a number' do
    let(:css) { <<-CSS }
      p {
        margin: 1.0001;
        padding: func(1.0001);
        top: 1.0001em;
      }
    CSS

    it { should_not report_lint }
  end
end
