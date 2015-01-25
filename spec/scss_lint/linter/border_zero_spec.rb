require 'spec_helper'

describe SCSSLint::Linter::BorderZero do
  context 'when a rule is empty' do
    let(:css) { <<-CSS }
      p {
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a property' do
    context 'contains a normal border' do
      let(:css) { <<-CSS }
        p {
          border: 1px solid #000;
        }
      CSS

      it { should_not report_lint }
    end

    context 'has a border of 0' do
      let(:css) { <<-CSS }
        p {
          border: 0;
        }
      CSS

      it { should_not report_lint }
    end

    context 'has a border of none' do
      let(:css) { <<-CSS }
        p {
          border: none;
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'has a border-top of none' do
      let(:css) { <<-CSS }
        p {
          border-top: none;
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'has a border-right of none' do
      let(:css) { <<-CSS }
        p {
          border-right: none;
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'has a border-bottom of none' do
      let(:css) { <<-CSS }
        p {
          border-bottom: none;
        }
      CSS

      it { should report_lint line: 2 }
    end

    context 'has a border-left of none' do
      let(:css) { <<-CSS }
        p {
          border-left: none;
        }
      CSS

      it { should report_lint line: 2 }
    end
  end

  context 'when a convention of `none` is preferred' do
    let(:linter_config) { { 'convention' => 'none' } }

    context 'and the border is `none`' do
      let(:css) { <<-CSS }
        p {
          border: none;
        }
      CSS

      it { should_not report_lint }
    end

    context 'and the border is `0`' do
      let(:css) { <<-CSS }
        p {
          border: 0;
        }
      CSS

      it { should report_lint }
    end

    context 'and the border is a non-zero value' do
      let(:css) { <<-CSS }
        p {
          border: 5px;
        }
      CSS

      it { should_not report_lint }
    end
  end
end
