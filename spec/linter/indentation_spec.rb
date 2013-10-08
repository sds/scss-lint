require 'spec_helper'

describe SCSSLint::Linter::Indentation do
  context 'when a line at the root level is indented' do
    let(:css) { <<-CSS }
      $var: 5px;
        $other: 10px;
    CSS

    it { should_not report_lint line: 1 }
    it { should report_lint line: 2 }
  end

  context 'when a line in a rule set is properly indented' do
    let(:css) { <<-CSS }
      p {
        margin: 0;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when lines in a rule set are not properly indented' do
    let(:css) { <<-CSS }
      p {
      margin: 0;
        padding: 1em;
      opacity: 0.5;
      }
    CSS

    it { should report_lint line: 2 }
    it { should_not report_lint line: 3 }
    it { should report_lint line: 4 }
  end

  context 'when selector of a nested rule set is not properly indented' do
    let(:css) { <<-CSS }
      p {
      em {
        font-style: italic;
      }
      }
    CSS

    it { should report_lint line: 2 }
    it { should_not report_lint line: 3 }
    it { should_not report_lint line: 4 }
  end

  context 'when multi-line selector of a nested rule set is not properly indented' do
    let(:css) { <<-CSS }
      p {
      b,
      em,
      i {
        font-style: italic;
      }
      }
    CSS

    it { should report_lint line: 2 }
    it { should_not report_lint line: 3 }
    it { should_not report_lint line: 4 }
    it { should_not report_lint line: 5 }
  end

  context 'when a property is on the same line as its rule selector' do
    let(:css) { 'h1 { margin: 5px; }' }
    it { should_not report_lint }
  end

  context 'when an argument list spans multiple lines' do
    let(:css) { <<-CSS }
      @include mixin(one,
                     two,
                     three);
    CSS

    it { should_not report_lint }
  end

  context 'when an argument list of an improperly indented script spans multiple lines' do
    let(:css) { <<-CSS }
      p {
      @include mixin(one,
                     two,
                     three);
      }
    CSS

    it { should report_lint line: 2 }
    it { should_not report_lint line: 3 }
    it { should_not report_lint line: 4 }
  end

  context 'when an if statement is incorrectly indented' do
    let(:css) { <<-CSS }
      $condition: true;
        @if $condition {
        padding: 0;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when an if statement is accompanied by a correctly indented else statement' do
    let(:css) { <<-CSS }
      @if $condition {
        padding: 0;
      } @else {
        margin: 0;
      }
    CSS

    it { should_not report_lint }
  end
end
