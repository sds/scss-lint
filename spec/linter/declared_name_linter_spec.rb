require 'spec_helper'

describe SCSSLint::Linter::DeclaredNameLinter do
  let(:engine) { SCSSLint::Engine.new(css) }
  let(:linter) { described_class.new }
  subject      { linter.lints }

  before do
    linter.run(engine)
  end

  context 'when no variable, functions, or mixin declarations exist' do
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

  context 'when a function is declared with a capital letter' do
    let(:css) { <<-EOS }
      @function badFunction() {
      }
    EOS

    it 'returns a lint' do
      subject.count.should == 1
    end
  end

  context 'when a function is declared with an underscore' do
    let(:css) { <<-EOS }
      @function bad_function() {
      }
    EOS

    it 'returns a lint' do
      subject.count.should == 1
    end
  end

  context 'when a mixin is declared with a capital letter' do
    let(:css) { <<-EOS }
      @mixin badMixin() {
      }
    EOS

    it 'returns a lint' do
      subject.count.should == 1
    end
  end

  context 'when a mixin is declared with an underscore' do
    let(:css) { <<-EOS }
      @mixin bad_mixin() {
      }
    EOS

    it 'returns a lint' do
      subject.count.should == 1
    end
  end
end
