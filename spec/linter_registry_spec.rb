require 'spec_helper'

describe SCSSLint::LinterRegistry do
  context 'when including the LinterRegistry module' do
    it 'adds the linter to the set of registered linters' do
      expect do
        class FakeLinter
          include SCSSLint::LinterRegistry
        end
      end.to change { SCSSLint::LinterRegistry.linters.count }.by(1)
    end
  end
end
