require 'spec_helper'

describe SCSSLint::Linter::EmptyRuleLinter do
  let(:engine) { SCSSLint::Engine.new(css) }
  let(:linter) { SCSSLint::Linter::EmptyRuleLinter.new }
  subject      { linter.lints }

  before do
    linter.run(engine)
  end

  context 'when rule is empty' do
    let(:css) { <<-CSS }
      p {
      }
    CSS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'reports the first line of the empty rule declaration for the lint' do
      subject.first.line.should == 1
    end
  end

  context 'when rule contains an empty nested rule' do
    let(:css) { <<-CSS }
      p {
        background: #000;
        display: none;
        margin: 5px;
        padding: 10px;
        a {
        }
      }
    CSS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'reports the first line of the empty rule declaration for the lint' do
      subject.first.line.should == 6
    end
  end
end
