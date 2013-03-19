require 'spec_helper'

describe SCSSLint::Linter::SortedPropertiesLinter do
  let(:engine) { SCSSLint::Engine.new(css) }
  let(:linter) { SCSSLint::Linter::SortedPropertiesLinter.new }
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

  context 'when rule contains properties in sorted order' do
    let(:css) { <<-EOS }
      p {
        background: #000;
        display: none;
        margin: 5px;
        padding: 10px;
      }
    EOS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when rule contains mixins followed by properties in sorted order' do
    let(:css) { <<-EOS }
      p {
        @include border-radius(5px);
        background: #000;
        display: none;
        margin: 5px;
        padding: 10px;
      }
    EOS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when rule contains nested rules after sorted properties' do
    let(:css) { <<-EOS }
      p {
        background: #000;
        display: none;
        margin: 5px;
        padding: 10px;
        a {
          color: #555;
        }
      }
    EOS

    it 'returns no lints' do
      subject.should be_empty
    end
  end

  context 'when rule contains properties in random order' do
    let(:css) { <<-EOS }
      p {
        padding: 5px;
        display: block;
        margin: 10px;
      }
    EOS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'returns a lint at the line of the first property in the rule set' do
      subject.first.line.should == 2
    end
  end

  context 'when there are multiple rules with out of order properties' do
    let(:css) { <<-EOS }
      p {
        display: block;
        background: #fff;
      }
      a {
        margin: 5px;
        color: #444;
      }
    EOS

    it 'returns all lints' do
      subject.count.should == 2
    end

    it 'reports the correct lines for all lints' do
      subject[0].line.should == 2
      subject[1].line.should == 6
    end
  end

  context 'when there are nested rules with out of order properties' do
    let(:css) { <<-EOS }
      p {
        display: block;
        background: #fff;
        a {
          margin: 5px;
          color: #444;
        }
      }
    EOS

    it 'returns both lints' do
      subject.count.should == 2
    end

    it 'reports the correct lines for each lint' do
      subject[0].line.should == 2
      subject[1].line.should == 5
    end
  end
end
