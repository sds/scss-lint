require 'spec_helper'

describe SCSSLint::Linter::Shorthand do
  context 'when a rule' do
    context 'is empty' do
      let(:css) { <<-CSS }
        p {
        }
      CSS

      it { should_not report_lint }
    end

    context 'contains properties with valid shorthand values' do
      let(:css) { <<-CSS }
        p {
          border-radius: 1px 2px 1px 3px;
          border-width: 1px;
          color: rgba(0, 0, 0, .5);
          margin: 1px 2px;
          padding: 0 0 1px;
        }
      CSS

      it { should_not report_lint }
    end
  end

  context 'when a property' do
    context 'has a value repeated 4 times' do
      let(:css) { <<-CSS }
        p {
          padding: 1px 1px 1px 1px;
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'has exactly two identical values' do
      let(:css) { <<-CSS }
        p {
          padding: 10px 10px;
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'appears to have two identical values, but cannot be shorthanded' do
      let(:css) { <<-CSS }
        p:before {
          content: ' ';
        }
      CSS

      it { should_not report_lint }
    end

    context 'has its first two values repeated' do
      let(:css) { <<-CSS }
        p {
          padding: 1px 2px 1px 2px;
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'has its first value repeated in the third position' do
      let(:css) { <<-CSS }
        p {
          padding: 1px 2px 1px;
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'has its second value repeated in the fourth position' do
      let(:css) { <<-CSS }
        p {
          padding: 1px 2px 3px 2px;
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'contains numeric values and function calls' do
      let(:css) { <<-CSS }
        p {
          margin: 10px percentage(1 / 100);
        }
      CSS

      it { should_not report_lint }
    end

    context 'contains a list of function calls that can be shortened' do
      let(:css) { <<-CSS }
        p {
          margin: percentage(1 / 100) percentage(1 / 100);
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'contains a list of function calls that cannot be shortened' do
      let(:css) { <<-CSS }
        p {
          margin: percentage(1 / 100) percentage(5 / 100);
        }
      CSS

      it { should_not report_lint }
    end

    context 'contains a list of variables that can be shortened' do
      let(:css) { <<-CSS }
        p {
          margin: $my-var 1px $my-var;
        }
      CSS

      it { should report_lint line: 2 }
    end
  end
end
