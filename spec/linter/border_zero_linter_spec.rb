require 'spec_helper'

describe SCSSLint::Linter::BorderZeroLinter do
  let(:engine) { SCSSLint::Engine.new(css) }
  let(:linter) { SCSSLint::Linter::BorderZeroLinter.new }
  subject      { linter.lints }

  before do
    linter.run(engine)
  end

  context 'when a rule is empty' do
    let(:css) { <<-EOS }
      p {
      }
    EOS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when a property' do
    context 'contains a normal border' do
      let(:css) { <<-EOS }
        p {
          border: 1px solid #000;
        }
      EOS

      it 'returns no lints' do
        subject.should be_empty
      end
    end

    context 'has a border of 0' do
      let(:css) { <<-EOS }
        p {
          border: 0;
        }
      EOS

      it 'returns a no lints' do
        subject.count.should == 0
      end
    end

    context 'has a border of none' do
      let(:css) { <<-EOS }
        p {
          border: none;
        }
      EOS

      it 'returns a lint' do
        subject.count.should == 1
      end

      it 'reports the correct line for the lint' do
        subject.first.line.should == 2
      end
    end

    context 'has a border-top of none' do
      let(:css) { <<-EOS }
        p {
          border-top: none;
        }
      EOS

      it 'returns a lint' do
        subject.count.should == 1
      end

      it 'reports the correct line for the lint' do
        subject.first.line.should == 2
      end
    end

    context 'has a border-right of none' do
      let(:css) { <<-EOS }
        p {
          border-right: none;
        }
      EOS

      it 'returns a lint' do
        subject.count.should == 1
      end

      it 'reports the correct line for the lint' do
        subject.first.line.should == 2
      end
    end

    context 'has a border-bottom of none' do
      let(:css) { <<-EOS }
        p {
          border-bottom: none;
        }
      EOS

      it 'returns a lint' do
        subject.count.should == 1
      end

      it 'reports the correct line for the lint' do
        subject.first.line.should == 2
      end
    end

    context 'has a border-left of none' do
      let(:css) { <<-EOS }
        p {
          border-left: none;
        }
      EOS

      it 'returns a lint' do
        subject.count.should == 1
      end

      it 'reports the correct line for the lint' do
        subject.first.line.should == 2
      end
    end
  end
end
