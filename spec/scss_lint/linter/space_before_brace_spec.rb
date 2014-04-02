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

  context 'when curly brace is in a single line rule set' do
    let(:css) { <<-CSS }
      .single-line-selector{color: #f00;}
    CSS

    it { should report_lint line: 1 }
  end

  context 'when using #{} interpolation' do
    let(:css) { <<-CSS }
      @mixin test-mixin($class, $prop, $pixels) {
        .\#{$class} {
          \#{$prop}: \#{$pixels}px;
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when blocks occupy a single line' do
    let(:linter_config) { { 'allow_single_line_padding' => allow_single_line_padding } }

    let(:css) { <<-CSS }
      p{ }
      p { }
      p           { &:before { } }
      p           { &:before{ } }
    CSS

    context 'and the `allow_extra_spaces` option is true' do
      let(:allow_single_line_padding) { true }

      it { should report_lint line: 1 }
      it { should_not report_lint line: 2 }
      it { should_not report_lint line: 3 }
      it { should report_lint line: 4 }
    end

    context 'and the `allow_extra_spaces` option is false' do
      let(:allow_single_line_padding) { false }

      it { should report_lint line: 1 }
      it { should_not report_lint line: 2 }
      it { should report_lint line: 3 }
      it { should report_lint line: 4 }
    end
  end
end
