require 'spec_helper'

describe SCSSLint::Linter::DeclaredNameLinter do
  let(:engine) { SCSSLint::Engine.new(css) }
  let(:linter) { described_class.new }
  subject      { linter.lints }

  before do
    linter.run(engine)
  end

  context 'when no variable, functions, or mixin declarations exist' do
    let(:css) { <<-CSS }
    CSS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when a variable name contains a hyphen' do
    let(:css) { <<-CSS }
      $content-padding: 10px;
    CSS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when a variable name contains an underscore' do
    let(:css) { <<-CSS }
      $content_padding: 10px;
    CSS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'returns the correct line for the lint' do
      subject.first.line.should == 1
    end
  end

  context 'when a variable name contains an uppercase character' do
    let(:css) { <<-CSS }
      $contentPadding: 10px;
    CSS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'returns the correct line for the lint' do
      subject.first.line.should == 1
    end
  end

  context 'when a function is declared with a capital letter' do
    let(:css) { <<-CSS }
      @function badFunction() {
      }
    CSS

    it 'returns a lint' do
      subject.count.should == 1
    end
  end

  context 'when a function is declared with an underscore' do
    let(:css) { <<-CSS }
      @function bad_function() {
      }
    CSS

    it 'returns a lint' do
      subject.count.should == 1
    end
  end

  context 'when a mixin is declared with a capital letter' do
    let(:css) { <<-CSS }
      @mixin badMixin() {
      }
    CSS

    it 'returns a lint' do
      subject.count.should == 1
    end
  end

  context 'when a mixin is declared with an underscore' do
    let(:css) { <<-CSS }
      @mixin bad_mixin() {
      }
    CSS

    it 'returns a lint' do
      subject.count.should == 1
    end
  end

  context 'when a referenced variable name has a capital letter' do
    let(:css) { <<-CSS }
      p {
        margin: $badVar;
      }
    CSS

    it 'returns a lint' do
      subject.count.should == 1
    end
  end

  context 'when a referenced variable name has an underscore' do
    let(:css) { <<-CSS }
      p {
        margin: $bad_var;
      }
    CSS

    it 'returns a lint' do
      subject.count.should == 1
    end
  end

  context 'when a referenced function name has a capital letter' do
    let(:css) { <<-CSS }
      p {
        margin: badFunc();
      }
    CSS

    it 'returns a lint' do
      subject.count.should == 1
    end
  end

  context 'when a referenced function name has an underscore' do
    let(:css) { <<-CSS }
      p {
        margin: bad_func();
      }
    CSS

    it 'returns a lint' do
      subject.count.should == 1
    end
  end

  context 'when an included mixin name has a capital letter' do
    let(:css) { <<-CSS }
      @include badMixin();
    CSS

    it 'returns a lint' do
      subject.count.should == 1
    end
  end

  context 'when an included mixin name has an underscore' do
    let(:css) { <<-CSS }
      @include bad_mixin();
    CSS

    it 'returns a lint' do
      subject.count.should == 1
    end
  end
end
