require 'spec_helper'

describe SCSSLint::Linter::UsageNameLinter do
  context 'when no invalid usages exist' do
    let(:css) { <<-CSS }
      p {
        margin: 0;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a referenced variable name has a capital letter' do
    let(:css) { <<-CSS }
      p {
        margin: $badVar;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a referenced variable name has an underscore' do
    let(:css) { <<-CSS }
      p {
        margin: $bad_var;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a referenced function name has a capital letter' do
    let(:css) { <<-CSS }
      p {
        margin: badFunc();
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a referenced function name has an underscore' do
    let(:css) { <<-CSS }
      p {
        margin: bad_func();
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when an included mixin name has a capital letter' do
    let(:css) { <<-CSS }
      @include badMixin();
    CSS

    it { should report_lint line: 1 }
  end

  context 'when an included mixin name has an underscore' do
    let(:css) { <<-CSS }
      @include bad_mixin();
    CSS

    it { should report_lint line: 1 }
  end
end
