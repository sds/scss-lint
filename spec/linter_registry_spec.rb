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

  describe '.extract_linters_from' do
    class SomeLinter; include SCSSLint::LinterRegistry; end
    class SomeOtherLinter < SomeLinter; end
    let(:linters) { [SomeLinter, SomeOtherLinter] }

    context 'when the linters exist' do
      let(:linter_names) { ['some_linter', 'some_other_linter'] }

      it 'returns the linters' do
        subject.extract_linters_from(linter_names).should == linters
      end
    end

    context "when the linters don't exist" do
      let(:linter_names) { ['some_random_linter'] }

      it 'raises an error' do
        expect do
          subject.extract_linters_from(linter_names)
        end.to raise_error(SCSSLint::NoSuchLinter)
      end
    end
  end
end
