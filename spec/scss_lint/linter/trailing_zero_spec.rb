require 'spec_helper'

describe SCSSLint::Linter::TrailingZero do
  context 'when no values exist' do
    let(:css) { 'p {}' }

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

  context 'when a unitless fractional value with no trailing zero exists' do
    let(:css) { <<-CSS }
      p {
        line-height: .5;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a negative unitless fractional value with no trailing zero exists' do
    let(:css) { <<-CSS }
      p {
        line-height: -.5;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a fractional value with units and no trailing zero exists' do
    let(:css) { <<-CSS }
      p {
        margin: .5em;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a negative fractional value with units and no trailing zero exists' do
    let(:css) { <<-CSS }
      p {
        margin: -.5em;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a fractional value with a trailing zero exists' do
    let(:css) { <<-CSS }
      p {
        line-height: .50;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a fractional value with units and a trailing zero exists' do
    let(:css) { <<-CSS }
      p {
        margin: .50em;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a negative fractional value with units and a trailing zero exists' do
    let(:css) { <<-CSS }
      p {
        margin: -.50em;
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

  context 'when multiple fractional values with trailing zeros exist' do
    let(:css) { <<-CSS }
      p {
        margin: 0.50em .50 0.10px .90pt;
      }
    CSS

    it { should report_lint count: 4, line: 2 }
  end

  context 'when trailing zeros appear in function arguments' do
    let(:css) { <<-CSS }
      p {
        margin: some-function(.50em, 0.40 0.30 .2);
      }
    CSS

    it { should report_lint count: 3, line: 2 }
  end

  context 'when trailing zeros appear in mixin arguments' do
    let(:css) { <<-CSS }
      p {
        @include some-mixin(0.50em, 0.40 0.30 .2);
      }
    CSS

    it { should report_lint count: 3, line: 2 }
  end

  context 'when trailiing zeros appear in variable declarations' do
    let(:css) { '$some-var: .50em;' }

    it { should report_lint line: 1 }
  end

  context 'when trailing zeros appear in named arguments' do
    let(:css) { <<-CSS }
      p {
        @include line-clamp($line-height: .90, $line-count: 2);
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when trailing zeros appear in parameter defaults' do
    let(:css) { <<-CSS }
      @mixin my-mixin($bad-value: .50, $good-value: .9, $string-value: ".90") {
        margin: $some-value;
        padding: $some-other-value;
      }
    CSS

    it { should report_lint count: 1, line: 1 }
  end
end
