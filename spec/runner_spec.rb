require 'spec_helper'

describe SCSSLint::Runner do
  let(:options) { {} }
  let(:runner)  { SCSSLint::Runner.new(options) }

  describe '#new' do
    context 'when the :ignored_linters option is specified' do
      let(:options) { { ignored_linters: ['FakeLinter2'] } }

      class FakeLinter1 < SCSSLint::Linter; include SCSSLint::LinterRegistry; end
      class FakeLinter2 < FakeLinter1; end

      before do
        SCSSLint::LinterRegistry.stub(:linters).and_return([FakeLinter1, FakeLinter2])
      end

      it 'restricts the set of linters that are run' do
        runner.linters.should_not include FakeLinter2
      end
    end
  end

  describe '#run' do
    let(:files) { ['dummy1.scss', 'dummy2.scss'] }
    subject     { runner.run(files) }

    it 'searches for lints in each file' do
      runner.should_receive(:find_lints).exactly(files.size).times
      subject
    end

    context 'when no files are given' do
      let(:files) { [] }

      it 'raises an error' do
        expect { subject }.to raise_error
      end
    end

    context 'when no linters are registered' do
      before do
        SCSSLint::LinterRegistry.stub(:linters) { [] }
      end

      it 'raises an error' do
        expect { subject }.to raise_error
      end
    end
  end
end
