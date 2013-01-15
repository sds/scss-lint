require 'spec_helper'

describe SCSSLint::Linter::TypeInIdSelectorLinter do
  let(:engine) { SCSSLint::Engine.new(css) }
  subject { SCSSLint::Linter::TypeInIdSelectorLinter.run(engine) }

  context 'when rule is just a type' do
    let(:css) { <<-EOS }
      p {
      }
    EOS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when rule is just an ID' do
    let(:css) { <<-EOS }
      #identifier {
      }
    EOS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when rule is just a class' do
    let(:css) { <<-EOS }
      .class {
      }
    EOS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when rule is a type with a class' do
    let(:css) { <<-EOS }
      a.class {
      }
    EOS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when rule is a type with an ID' do
    let(:css) { <<-EOS }
      a#identifier {
      }
    EOS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'reports the correct line' do
      subject.first.line.should == 1
    end
  end

  context 'when rule contains multiple selectors' do
    context 'when all of the selectors are just IDs, classes, or types' do
      let(:css) { <<-EOS }
        #identifier,
        .class,
        a {
        }
      EOS

      it 'returns no lints' do
        subject.should be_empty
      end
    end

    context 'when one of the selectors is a type and class' do
      let(:css) { <<-EOS }
        #identifier,
        a.class {
        }
      EOS

      it 'returns no lints' do
        subject.should be_empty
      end
    end

    context 'when one of the selectors is a type and ID' do
      let(:css) { <<-EOS }
        #identifier,
        a#my-id {
        }
      EOS

      it 'returns a lint' do
        subject.count.should == 1
      end

      it 'reports the correct line' do
        subject.first.line.should == 2
      end
    end
  end

  context 'when rule contains a nested rule with type and ID' do
    let(:css) { <<-EOS }
      p {
        a#identifier {
        }
      }
    EOS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'reports the correct line' do
      subject.first.line.should == 2
    end
  end
end
