require 'spec_helper'

describe SCSSLint::Linter::HexLinter do
  let(:engine) { SCSSLint::Engine.new(css) }
  let(:linter) { SCSSLint::Linter::HexLinter.new }
  subject      { linter.lints }

  before do
    linter.run(engine)
  end

  context 'when rule is empty' do
    let(:css) { <<-EOS }
      p {
      }
    EOS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when rule contains properties with valid hex codes' do
    let(:css) { <<-EOS }
      p {
        background: #ccc;
        color: #1234ab;
      }
    EOS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when a property has a hex code with uppercase characters' do
    let(:css) { <<-EOS }
      p {
        color: #DDD;
      }
    EOS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'reports the correct line for the lint' do
      subject.first.line.should == 2
    end
  end

  context 'when a property has a hex code that can be condensed to 3 digits' do
    let(:css) { <<-EOS }
      p {
        color: #11bb44;
      }
    EOS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'reports the correct line for the lint' do
      subject.first.line.should == 2
    end
  end

  context 'when rule contains multiple properties with invalid hex codes' do
    let(:css) { <<-EOS }
      p {
        background: #000000;
        color: #DDD;
      }
    EOS

    it 'returns all lints' do
      subject.count.should == 2
    end

    it 'reports correct lines for each lint' do
      subject[0].line.should == 2
      subject[1].line.should == 3
    end
  end
end
