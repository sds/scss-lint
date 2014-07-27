require 'spec_helper'

describe SCSSLint::Linter::Compass::PropertyWithMixin do
  context 'when a rule has a property with an equivalent Compass mixin' do
    let(:css) { <<-CSS }
      p {
        opacity: .5;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a rule includes a Compass property mixin' do
    let(:css) { <<-CSS }
      p {
        @include opacity(.5);
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a rule does not have a property with a corresponding Compass mixin' do
    let(:css) { <<-CSS }
      p {
        margin: 0;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a rule includes display: inline-block' do
    let(:css) { <<-CSS }
      p {
        display: inline-block;
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when properties are ignored' do
    let(:linter_config) { { 'ignore' => %w[inline-block] } }

    let(:css) { <<-CSS }
      p {
        display: inline-block;
      }
    CSS

    it { should_not report_lint }
  end
end
