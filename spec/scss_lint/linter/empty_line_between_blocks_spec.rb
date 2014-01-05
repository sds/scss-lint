require 'spec_helper'

describe SCSSLint::Linter::EmptyLineBetweenBlocks do
  context 'when there are multiple rule sets' do
    context 'with blank lines between them' do
      let(:css) { <<-CSS }
        a {
        }

        b {
        }

        p {
        }
      CSS

      it { should_not report_lint }
    end

    context 'with no blank line between them' do
      let(:css) { <<-CSS }
        a {
        }
        b {
        }
        p {
        }
      CSS

      it { should report_lint line: 2 }
      it { should report_lint line: 4 }
      it { should_not report_lint line: 6 }
    end
  end

  context 'when a rule set contains nested rule sets' do
    context 'and the nested rule sets have no blank line between them' do
      let(:css) { <<-CSS }
        p {
          a {
          }
          b {
          }
        }
      CSS

      it { should report_lint line: 3 }
      it { should_not report_lint line: 5 }
    end

    context 'and the nested rule sets have a blank line between them' do
      let(:css) { <<-CSS }
        p {
          a {
          }

          b {
          }
        }
      CSS

      it { should_not report_lint }
    end

    context 'and the nested rule set has a property preceding it' do
      let(:css) { <<-CSS }
        p {
          margin: 0;
          a {
          }
        }
      CSS

      it { should report_lint line: 3 }
    end

    context 'and the nested rule set has a property and empty line preceding it' do
      let(:css) { <<-CSS }
        p {
          margin: 0;

          a {
          }
        }
      CSS

      it { should_not report_lint }
    end
  end

  context 'when mixins are defined' do
    context 'and there is no blank line between them' do
      let(:css) { <<-CSS }
        @mixin mixin1() {
        }
        @mixin mixin2() {
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'and there is a blank line between them' do
      let(:css) { <<-CSS }
        @mixin mixin1() {
        }

        @mixin mixin2() {
        }
      CSS

      it { should_not report_lint }
    end
  end

  context 'when mixins are included without content' do
    let(:css) { <<-CSS }
      p {
        @include mixin1();
        property: blah;
        @include mixin2(4);
      }
    CSS

    it { should_not report_lint }
  end

  context 'when mixins are included with content' do
    context 'and there is no blank line between them' do
      let(:css) { <<-CSS }
        @include mixin1() {
          property: value;
        }
        @include mixin2() {
          property: value;
        }
      CSS

      it { should report_lint line: 3 }
    end

    context 'and there is a blank line between them' do
      let(:css) { <<-CSS }
        @include mixin1() {
          property: value;
        }

        @include mixin2() {
          property: value;
        }
      CSS

      it { should_not report_lint }
    end
  end

  context 'when functions are defined' do
    context 'and there is no blank line between them' do
      let(:css) { <<-CSS }
        @function func1() {
        }
        @function func2() {
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'and there is a blank line between them' do
      let(:css) { <<-CSS }
        @function func1() {
        }

        @function func2() {
        }
      CSS

      it { should_not report_lint }
    end
  end

  context 'when a rule set is followed by a comment' do
    let(:css) { <<-CSS }
      a {
      }
      // This is a comment
      p {
      }
    CSS

    it { should report_lint line: 2 }
  end

  context 'when a rule set is preceded by a comment' do
    let(:css) { <<-CSS }
      a {
      }

      // This is a comment
      p {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when there are multiple placeholder rule sets' do
    context 'with blank lines between them' do
      let(:css) { <<-CSS }
        %a {
        }

        %b {
        }

        %c {
        }
      CSS

      it { should_not report_lint }
    end

    context 'with no blank line between them' do
      let(:css) { <<-CSS }
        %a {
        }
        %b {
        }
        %c {
        }
      CSS

      it { should report_lint line: 2 }
      it { should report_lint line: 4 }
      it { should_not report_lint line: 6 }
    end
  end
end
