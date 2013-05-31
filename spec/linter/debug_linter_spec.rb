require 'spec_helper'

describe SCSSLint::Linter::DebugLinter do
  let(:engine) { SCSSLint::Engine.new(css) }
  let(:linter) { described_class.new }
  subject      { linter.lints }

  before do
    linter.run(engine)
  end

  context 'when no debug statements are present' do
    let(:css) { <<-CSS }
      p {
        color: #fff;
      }
    CSS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when a debug statement is present' do
    let(:css) { <<-CSS }
      @debug 'This is a debug statement';
    CSS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'reports the line of the debug statement for the lint' do
      subject.first.line.should == 1
    end
  end
end
