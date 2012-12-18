require 'spec_helper'

describe SCSSLint::Linter::ZeroUnitLinter do
  let(:engine) { SCSSLint::Engine.new(css) }
  subject { SCSSLint::Linter::ZeroUnitLinter.run(engine) }

  context 'when no properties exist' do
    let(:css) { <<-EOS }
      p {
      }
    EOS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when properties with unit-less zeros exist' do
    let(:css) { <<-EOS }
      p {
        margin: 0;
      }
    EOS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when properties with non-zero values exist' do
    let(:css) { <<-EOS }
      p {
        margin: 5px;
        line-height: 1.5em;
      }
    EOS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when properties with zero values contain units' do
    let(:css) { <<-EOS }
      p {
        margin: 0px;
      }
    EOS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'returns the correct line for the lint' do
      subject.first.line.should == 2
    end
  end
end
