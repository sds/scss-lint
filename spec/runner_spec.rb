require 'spec_helper'

describe SCSSLint::Runner do
  let(:options) { {} }
  let(:runner)  { SCSSLint::Runner.new(options) }

  class FakeLinter1 < SCSSLint::Linter; include SCSSLint::LinterRegistry; end
  class FakeLinter2 < FakeLinter1; end

  before do
    SCSSLint::LinterRegistry.stub(:linters).and_return([FakeLinter1, FakeLinter2])
  end

  describe '#new' do
    context 'when the :excluded_linters option is specified' do
      let(:options) { { excluded_linters: ['FakeLinter2'] } }

      it 'removes the excluded linter from the set of linters' do
        runner.linters.map(&:class).should_not include FakeLinter2
      end

      it 'leaves the rest of the linters in the set of linters' do
        runner.linters.map(&:class).should include FakeLinter1
      end
    end

    context 'when the :included_linters option is specified' do
      let(:options) { { included_linters: ['FakeLinter1'] } }

      it 'includes only the specified linter' do
        runner.linters.map(&:class).should include FakeLinter1
      end
    end

    context 'when :include_linters and :exclude_linters are specified' do
      let(:options) do
        {
          included_linters: %w[FakeLinter1 FakeLinter2],
          excluded_linters: ['FakeLinter2'],
        }
      end

      it 'includes all included linters' do
        runner.linters.map(&:class).should include FakeLinter1
      end

      it 'does not include any excluded linters' do
        runner.linters.map(&:class).should_not include FakeLinter2
      end
    end

    context 'when neither included or excluded linters is specified' do
      let(:options) { {} }

      it 'includes all registered linters' do
        runner.linters.map(&:class).should == [FakeLinter1, FakeLinter2]
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
