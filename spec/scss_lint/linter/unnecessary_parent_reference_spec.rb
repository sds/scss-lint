require 'spec_helper'

describe SCSSLint::Linter::UnnecessaryParentReference do
  context 'when an amperand precedes a direct descendant operator' do
    let(:css) { <<-CSS }
      p {
        & > a {}
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when an amperand precedes a general child' do
    let(:css) { <<-CSS }
      p {
        & a {}
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when an amperand is chained with class' do
    let(:css) { <<-CSS }
      p {
        &.foo {}
      }
    CSS

    it { should_not report_lint }
  end

  context 'when an amperand follows a direct descendant operator' do
    let(:css) { <<-CSS }
      p {
        .foo > & {}
      }
    CSS

    it { should_not report_lint }
  end

  context 'when an ampersand precedes a sibling operator' do
    let(:css) { <<-CSS }
      p {
        & + & {}
        & ~ & {}
      }
    CSS

    it { should_not report_lint }
  end

  context 'when an amperand is used in a comma sequence to DRY up code' do
    let(:css) { <<-CSS }
      p {
        &,
        .foo,
        .bar {
          margin: 0;
        }
      }
    CSS

    it { should_not report_lint }
  end

  context 'when an ampersand is used by itself' do
    let(:css) { <<-CSS }
      p {
        & {}
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when an ampersand is used in concatentation' do
    let(:css) { <<-CSS }
      .icon {
        &-small {}
      }
    CSS

    it { should_not report_lint }
  end
end
