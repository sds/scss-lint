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
end
