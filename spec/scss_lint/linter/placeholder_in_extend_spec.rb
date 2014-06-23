require 'spec_helper'

describe SCSSLint::Linter::PlaceholderInExtend do
  context 'when extending with a class' do
    let(:css) { <<-CSS }
      p {
        @extend .error;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when extending with a type' do
    let(:css) { <<-CSS }
      p {
        @extend span;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when extending with an id' do
    let(:css) { <<-CSS }
      p {
        @extend #some-identifer;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when extending with a placeholder' do
    let(:css) { <<-CSS }
      p {
        @extend %placeholder;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when extending with a selector whose prefix is not a placeholder' do
    let(:css) { <<-CSS }
      p {
        @extend .blah-\#{$dynamically_generated_name};
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when extending with a selector whose prefix is dynamic' do
    let(:css) { <<-CSS }
      p {
        @extend \#{$dynamically_generated_placeholder_name};
      }
    CSS

    it { should_not report_lint }
  end
end
