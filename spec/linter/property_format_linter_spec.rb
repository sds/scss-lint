require 'spec_helper'

describe SCSSLint::Linter::PropertyFormatLinter do
  let(:engine) { SCSSLint::Engine.new(css) }
  let(:linter) { described_class.new }
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

  context 'when rule contains properties with spaces after the colon' do
    let(:css) { <<-EOS }
      p {
        background: #000;
        margin: 5px;
      }
    EOS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when a valid property declaration is followed by a comment' do
    let(:css) { <<-EOS }
      p {
        background: #000; // This is a comment
        color: #fff; /* This is another comment */
      }
    EOS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when a property declaration does not have a space after the colon' do
    let(:css) { <<-EOS }
      p {
        color:#fff;
      }
    EOS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'returns the correct line for the lint' do
      subject.first.line.should == 2
    end
  end

  context 'when a property declaration has a space before the colon' do
    let(:css) { <<-EOS }
      p {
        color : #fff;
      }
    EOS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'returns the correct line for the lint' do
      subject.first.line.should == 2
    end
  end

  context 'when a property declaration has more than one space after the colon' do
    let(:css) { <<-EOS }
      p {
        color:  #fff;
      }
    EOS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'returns the correct line for the lint' do
      subject.first.line.should == 2
    end
  end

  context 'when a property declaration has spaces before the semicolon' do
    let(:css) { <<-EOS }
      p {
        color: #fff ;
      }
    EOS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'returns the correct line for the lint' do
      subject.first.line.should == 2
    end
  end

  context 'when a property declaration spans two lines' do
    let(:css) { <<-EOS }
      p {
        color:
          #f00;
      }
    EOS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'returns the correct line for the lint' do
      subject.first.line.should == 3
    end
  end

  context 'when a property declaration has no space in a nested rule' do
    let(:css) { <<-EOS }
      p {
        color: #000;
        a {
          color:#f00;
        }
      }
    EOS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'returns the correct line for the lint' do
      subject.first.line.should == 4
    end
  end

  context 'when a property declaration has no semi-colon ending it' do
    let(:css) { <<-EOS }
      p {
        color: #000;
        background: #fff
      }
    EOS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'returns the correct line for the lint' do
      subject.first.line.should == 4
    end
  end

  context 'with a nested property' do
    context 'when there is a value on the namespace' do
      let(:css) { <<-EOS }
        p {
          font: 2px/3px {
            family: sans-serif;
            weight: bold;
          }
        }
      EOS

      it 'returns no lints' do
        subject.should be_empty
      end
    end

    context 'when there is no value on the namespace' do
      let(:css) { <<-EOS }
        p {
          font: {
            family: sans-serif;
            size: 18px;
          }
        }
      EOS

      it 'returns no lints' do
        subject.should be_empty
      end
    end
  end

  context 'with valid property whose name is interpolated' do
    let(:css) { <<-EOS }
      p {
        margin-\#{$side}: $value;
      }
    EOS

    it 'returns no lints' do
      subject.should be_empty
    end
  end
end
