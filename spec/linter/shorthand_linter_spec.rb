require 'spec_helper'

describe SCSSLint::Linter::ShorthandLinter do
  let(:engine) { SCSSLint::Engine.new(css) }
  subject { SCSSLint::Linter::ShorthandLinter.run(engine) }

  context 'when a rule' do
    context 'is empty' do
      let(:css) { <<-EOS }
        p {
        }
      EOS

      it 'returns no lints' do
        subject.should be_empty
      end
    end

    context 'contains properties with valid shorthand values' do
      let(:css) { <<-EOS }
        p {
          border-radius: 1px 2px 1px 3px;
          border-width: 1px;
          color: rgba(0, 0, 0, .5);
          margin: 1px 2px;
          padding: 0 0 1px;
        }
      EOS

      it 'returns no lints' do
        subject.should be_empty
      end
    end
  end

  context 'when a property' do
    context 'has a value repeated 4 times' do
      let(:css) { <<-EOS }
        p {
          padding: 1px 1px 1px 1px;
        }
      EOS

      it 'returns a lint' do
        subject.count.should == 1
      end

      it 'reports the correct line for the lint' do
        subject.first.line.should == 2
      end
    end

    context 'has its first two values repeated' do
      let(:css) { <<-EOS }
        p {
          padding: 1px 2px 1px 2px;
        }
      EOS

      it 'returns a lint' do
        subject.count.should == 1
      end

      it 'reports correct lines for each lint' do
        subject.first.line.should == 2
      end
    end

    context 'has its first value repeated in the third position' do
      let(:css) { <<-EOS }
        p {
          padding: 1px 2px 1px;
        }
      EOS

      it 'returns a lint' do
        subject.count.should == 1
      end

      it 'reports correct lines for each lint' do
        subject.first.line.should == 2
      end
    end

    context 'has its second value repeated in the fourth position' do
      let(:css) { <<-EOS }
        p {
          padding: 1px 2px 3px 2px;
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
