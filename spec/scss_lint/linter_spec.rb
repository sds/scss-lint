require 'spec_helper'

describe SCSSLint::Linter do
  describe 'control comments' do
    before do
      @linter1 = SCSSLint::Linter::Fake1.new
      @linter2 = SCSSLint::Linter::Fake2.new

      initial_indent = css[/\A(\s*)/, 1]
      normalized_css = css.gsub(/^#{initial_indent}/, '')

      @linter1.run(SCSSLint::Engine.new(normalized_css), {})
      @linter2.run(SCSSLint::Engine.new(normalized_css), {})
    end

    module SCSSLint
      class Linter::Fake1 < SCSSLint::Linter
        def visit_prop(node)
          return unless node.value.to_sass.strip == 'fail1'
          add_lint(node, 'everything offends me')
        end
      end

      class Linter::Fake2 < SCSSLint::Linter
        def visit_prop(node)
          return unless node.value.to_sass.strip == 'fail2'
          add_lint(node, 'everything offends me too')
        end
      end
    end

    context 'when a disable is not present' do
      let(:css) { <<-CSS }
        p {
          border: fail1;

          a {
            border: fail1;
          }
        }
      CSS

      it { @linter1.should report_lint }
    end

    context 'when a disable is present at the top level' do
      let(:css) { <<-CSS }
        // scss-lint:disable Fake1
        p {
          border: fail1;

          a {
            border: fail1;
          }
        }
      CSS

      it { @linter1.should_not report_lint }
    end

    context 'when a disable is present at the top level for one linter but not the other' do
      let(:css) { <<-CSS }
        // scss-lint:disable Fake1
        p {
          border: fail1;
        }
        p {
          border: fail2;
        }
      CSS

      it { @linter1.should_not report_lint }
      it { @linter2.should report_lint }
    end

    context 'when a linter is disabled then enabled again' do
      let(:css) { <<-CSS }
        // scss-lint:disable Fake1
        p {
          border: fail1;
        }
        // scss-lint:enable Fake1
        p {
          border: fail1;
        }
      CSS

      it { @linter1.should_not report_lint line: 3 }
      it { @linter1.should report_lint line: 7 }
    end

    context 'when a linter is disabled within a rule' do
      let(:css) { <<-CSS }
        p {
          // scss-lint:disable Fake1
          border: fail1;

          a {
            border: fail1;
          }
        }

        p {
          border: fail1;
        }
      CSS

      it { @linter1.should_not report_lint line: 3 }
      it { @linter1.should_not report_lint line: 6 }
      it { @linter1.should report_lint line: 11 }
    end

    context 'when more than one linter is disabled' do
      let(:css) { <<-CSS }
        // scss-lint:disable Fake1, Fake2
        p {
          border: fail1;
        }

        p {
          border: fail2;
        }
      CSS

      it { @linter1.should_not report_lint }
      it { @linter2.should_not report_lint }
    end

    context 'when more than one linter is disabled without spaces between the linter names' do
      let(:css) { <<-CSS }
        // scss-lint:disable Fake1,Fake2
        p {
          border: fail1;
        }

        p {
          border: fail2;
        }
      CSS

      it { @linter1.should_not report_lint }
      it { @linter2.should_not report_lint }
    end

    context 'when two linters are disabled and only one is reenabled' do
      let(:css) { <<-CSS }
        // scss-lint:disable Fake1, Fake2
        p {
          border: fail1;
        }
        // scss-lint:enable Fake1

        p {
          margin: fail1;
          border: fail2;
        }
      CSS

      it { @linter1.should_not report_lint line: 3 }
      it { @linter2.should_not report_lint }
      it { @linter1.should report_lint line: 8 }
    end

    context 'when all linters are disabled' do
      let(:css) { <<-CSS }
        // scss-lint:disable all
        p {
          border: fail1;
        }

        p {
          margin: fail1;
          border: fail2;
        }
      CSS

      it { @linter1.should_not report_lint }
      it { @linter2.should_not report_lint }
    end

    context 'when all linters are disabled and then one is re-enabled' do
      let(:css) { <<-CSS }
        // scss-lint:disable all
        p {
          border: fail1;
        }
        // scss-lint:enable Fake1

        p {
          margin: fail1;
          border: fail2;
        }
      CSS

      it { @linter1.should_not report_lint line: 3 }
      it { @linter2.should_not report_lint }
      it { @linter1.should report_lint line: 8 }
    end
  end
end
