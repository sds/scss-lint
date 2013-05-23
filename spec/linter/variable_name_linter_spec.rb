require 'spec_helper'

describe SCSSLint::Linter::VariableNameLinter do
  let(:engine) { SCSSLint::Engine.new(css) }
  let(:linter) { SCSSLint::Linter::VariableNameLinter.new }
  subject      { linter.lints }

  before do
    linter.run(engine)
  end

  context 'when no variables exist' do
    let(:css) { <<-EOS }
    EOS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when a variable name contains a hyphen' do
    let(:css) { <<-EOS }
      $content-padding: 10px;
    EOS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when a variable name contains an underscore' do
    let(:css) { <<-EOS }
      $content_padding: 10px;
    EOS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'returns the correct line for the lint' do
      subject.first.line.should == 1
    end
  end

  context 'when a variable name contains an uppercase character' do
    let(:css) { <<-EOS }
      $contentPadding: 10px;
    EOS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'returns the correct line for the lint' do
      subject.first.line.should == 1
    end
  end
end
