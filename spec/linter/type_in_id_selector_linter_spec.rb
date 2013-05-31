require 'spec_helper'

describe SCSSLint::Linter::TypeInIdSelectorLinter do
  let(:engine) { SCSSLint::Engine.new(css) }
  let(:linter) { described_class.new }
  subject      { linter.lints }

  before do
    linter.run(engine)
  end

  context 'when rule is just a type' do
    let(:css) { <<-CSS }
      p {
      }
    CSS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when rule is just an ID' do
    let(:css) { <<-CSS }
      #identifier {
      }
    CSS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when rule is just a class' do
    let(:css) { <<-CSS }
      .class {
      }
    CSS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when rule is a type with a class' do
    let(:css) { <<-CSS }
      a.class {
      }
    CSS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when rule is a type with an ID' do
    let(:css) { <<-CSS }
      a#identifier {
      }
    CSS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'reports the correct line' do
      subject.first.line.should == 1
    end
  end

  context 'when rule contains multiple selectors' do
    context 'when all of the selectors are just IDs, classes, or types' do
      let(:css) { <<-CSS }
        #identifier,
        .class,
        a {
        }
      CSS

      it 'returns no lints' do
        subject.should be_empty
      end
    end

    context 'when one of the selectors is a type and class' do
      let(:css) { <<-CSS }
        #identifier,
        a.class {
        }
      CSS

      it 'returns no lints' do
        subject.should be_empty
      end
    end

    context 'when one of the selectors is a type and ID' do
      let(:css) { <<-CSS }
        #identifier,
        a#my-id {
        }
      CSS

      it 'returns a lint' do
        subject.count.should == 1
      end

      it 'reports the correct line' do
        subject.first.line.should == 2
      end
    end
  end

  context 'when rule contains a nested rule with type and ID' do
    let(:css) { <<-CSS }
      p {
        a#identifier {
        }
      }
    CSS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'reports the correct line' do
      subject.first.line.should == 2
    end
  end
end
