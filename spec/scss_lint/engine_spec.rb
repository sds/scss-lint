require 'spec_helper'

describe SCSSLint::Engine do
  let(:engine) { described_class.new(css) }

  context 'when a @media directive is present' do
    let(:css) { <<-CSS }
      @media only screen {
      }
    CSS

    it 'has a parse tree' do
      engine.tree.should_not be_nil
    end
  end

  context 'when the file being linted has an invalid byte sequence' do
    let(:css) { "\xC0\u0001" }

    it 'raises a FileEncodingError' do
      expect { engine }.to raise_error(SCSSLint::FileEncodingError)
    end
  end
end
