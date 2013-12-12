require 'spec_helper'

describe SCSSLint::Linter::Comment do
  context 'when no comments exist' do
    let(:css) { <<-CSS }
      p {
        margin: 0;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when comment is a single line comment' do
    let(:css) { '// Single line comment' }

    it { should_not report_lint }
  end

  context 'when comment is a single line comment at the end of a line' do
    let(:css) { <<-CSS }
      p {
        margin: 0; // Comment at end of line
      }
    CSS

    it { should_not report_lint }
  end

  context 'when comment is a multi-line comment' do
    let(:css) { <<-CSS }
      h1 {
        color: #eee;
      }
      /*
       * This is a multi-line comment that should report a lint
       */
      p {
        color: #DDD;
      }
    CSS

    it { should report_lint line: 4 }
  end

  context 'when multi-line-style comment is a at the end of a line' do
    let(:css) { <<-CSS }
      h1 {
        color: #eee; /* This is a comment */
      }
    CSS

    it { should report_lint line: 2 }
  end
end
