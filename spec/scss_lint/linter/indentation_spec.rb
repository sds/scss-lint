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

  context 'when @at-root directive contains correctly indented children' do
    let(:css) { <<-CSS }
      .block {
        @at-root {
          .something {}
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when @at-root directive with an inline selector contains correctly indented children' do
    let(:css) { <<-CSS }
      .block {
        @at-root .something {
          .something-else {}
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when @at-root directive with no inline selector contains comment' do
    let(:css) { <<-CSS }
      @at-root {
        // A comment that causes a crash
        .something-else {}
      }
    CSS

    it { should_not report_lint }
  end

  context 'when the indentation width has been explicitly set' do
    let(:linter_config) { { 'width' => 3 } }

    let(:css) { <<-CSS }
      p {
        margin: 0;
         padding: 5px;
      }
    CSS

    it { should report_lint line: 2 }
    it { should_not report_lint line: 3 }
  end

  context 'when there are selectors across multiple lines' do
    let(:css) { <<-CSS }
      .class1,
      .class2 {
        margin: 0;
        padding: 5px;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when there are selectors across multiple lines with a single line block' do
    let(:css) { <<-CSS }
      .class1,
      .class2 { margin: 0; }
    CSS

    it { should_not report_lint }
  end

  context 'when a comment node precedes a node' do
    let(:css) { <<-CSS }
      // A comment
      $var: 1;
    CSS

    it { should_not report_lint }
  end

  context 'when a line is indented with tabs' do
    let(:css) { <<-CSS }
      p {
      \tmargin: 0;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a line contains a mix of tabs and spaces' do
    let(:css) { <<-CSS }
      p {
        \tmargin: 0;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when tabs are preferred' do
    let(:linter_config) { { 'character' => 'tab', 'width' => 1 } }

    context 'and the line is indented correctly' do
      let(:css) { <<-CSS }
        p {
        \tmargin: 0;
        }
      CSS

      it { should_not report_lint }
    end

    context 'and the line is incorrectly indented' do
      let(:css) { <<-CSS }
        p {
        \t\tmargin: 0;
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'and the line is indented with spaces' do
      let(:css) { <<-CSS }
        p {
          margin: 0;
        }
      CSS

      it { should report_lint line: 2 }
    end
  end
end
