require 'spec_helper'

describe SCSSLint::Linter::DebugLinter do
  let(:engine) { SCSSLint::Engine.new(css) }

  before do
    subject.run(engine)
  end

  context 'when no debug statements are present' do
    let(:css) { <<-CSS }
      p {
        color: #fff;
      }
    CSS

    it { should_not report_lint }
  end

  context 'when a debug statement is present' do
    let(:css) { <<-CSS }
      @debug 'This is a debug statement';
    CSS

    it { should report_lint line: 1 }
  end
end
