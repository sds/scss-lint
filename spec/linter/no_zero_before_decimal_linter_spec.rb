require 'spec_helper'

describe SCSSLint::Linter::NoZeroBeforeDecimalLinter do
  context 'when no values exist' do
    let(:css) { <<-CSS }
      p {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a zero exists' do
    let(:css) { <<-CSS }
      p {
        margin: 0;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when an integer value exists' do
    let(:css) { <<-CSS }
      p {
        line-height: 2;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when an integer value with units exists' do
    let(:css) { <<-CSS }
      p {
        margin: 5px;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a unitless fractional value with no leading zero exists' do
    let(:css) { <<-CSS }
      p {
        line-height: .5;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a negative unitless fractional value with no leading zero exists' do
    let(:css) { <<-CSS }
      p {
        line-height: -.5;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a fractional value with units and no leading zero exists' do
    let(:css) { <<-CSS }
      p {
        margin: .5em;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a negative fractional value with units and no leading zero exists' do
    let(:css) { <<-CSS }
      p {
        margin: -.5em;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a fractional value with a leading zero exists' do
    let(:css) { <<-CSS }
      p {
        line-height: 0.5;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a fractional value with units and a leading zero exists' do
    let(:css) { <<-CSS }
      p {
        margin: 0.5em;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a negative fractional value with units and a leading zero exists' do
    let(:css) { <<-CSS }
      p {
        margin: -0.5em;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a fractional value with a mantissa ending in zero exists' do
    let(:css) { <<-CSS }
      p {
        line-height: 10.5;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when multiple fractional values with leading zeros exist' do
    let(:css) { <<-CSS }
      p {
        margin: 0.5em 0.5 0.1px 0.9pt;
      }
    CSS

    it { should report_lint count: 4, line: 2 }
  end
end
