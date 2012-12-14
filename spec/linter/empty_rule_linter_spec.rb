require 'spec_helper'

describe SCSSLint::Linter::EmptyRuleLinter do
  let(:engine) { SCSSLint::Engine.new(css) }
  subject { SCSSLint::Linter::EmptyRuleLinter.run(engine) }

  context 'when rule is empty' do
    let(:css) { <<-EOS }
      p {
      }
    EOS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'reports the first line of the empty rule declaration for the lint' do
      subject.first.line.should == 1
    end
  end

  context 'when rule contains an empty nested rule' do
    let(:css) { <<-EOS }
      p {
        background: #000;
        display: none;
        margin: 5px;
        padding: 10px;
        a {
        }
      }
    EOS

    it 'returns a lint' do
      subject.count.should == 1
    end

    it 'reports the first line of the empty rule declaration for the lint' do
      subject.first.line.should == 6
    end
  end
end
