require 'spec_helper'

describe SCSSLint::Linter::SingleLinePerSelector do
  context 'when rule has one selector' do
    let(:css) { <<-CSS }
      p {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule has one selector on each line' do
    let(:css) { <<-CSS }
      p,
      a {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule contains multiple selectors on the same line' do
    let(:css) { <<-CSS }
      .first,
      .second,
      .third, .fourth,
      .fifth {
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when commas are not at the end of the line' do
    let(:css) { <<-CSS }
      .foo
      , .bar {
      }
    CSS

    it { should report_lint }
  end

  context 'when commas are on their own line' do
    let(:css) { <<-CSS }
      .foo
      ,
      .bar {
      }
    CSS

    it { should report_lint }
  end

  context 'when nested rule contains multiple selectors on the same line' do
    let(:css) { <<-CSS }
      #foo {
        .first,
        .second,
        .third, .fourth,
        .fifth {
        }
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when rule contains interpolated selectors' do
    let(:css) { <<-CSS }
      .first,
      \#{interpolated-selector}.thing,
      .third {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule contains an interpolated selector not on its own line' do
    let(:css) { <<-CSS }
      .first,
      .second, \#{interpolated-selector}.thing,
      .fourth {
      }
    CSS

    it { should report_lint line: 1 }
  end

  context 'when rule contains interpolated selectors with nth function' do
    let(:css) { <<-CSS }
      $foo: bar baz;
      \#{nth($foo, 1)}.thing {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when rule contains an inline comment' do
    let(:css) { <<-CSS }
      .first,  /* A comment */
      .second, // Another comment
      .third {
      }
    CSS

    it { should_not report_lint }
  end
end
