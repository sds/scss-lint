require 'spec_helper'

describe SCSSLint::Runner do
  let(:runner) { SCSSLint::Runner.new }

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
