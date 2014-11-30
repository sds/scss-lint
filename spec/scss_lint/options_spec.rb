require 'spec_helper'
require 'scss_lint/options'

describe SCSSLint::Options do
  describe '#parse' do
    subject { super().parse(args) }

    context 'when no arguments are specified' do
      let(:args) { [] }

      it { should be_a Hash }

      it 'defines no files to lint by default' do
        subject[:files].should be_empty
      end

      it 'specifies the DefaultReporter by default' do
        subject[:reporters].first.should include SCSSLint::Reporter::DefaultReporter
      end

      it 'outputs to STDOUT' do
        subject[:reporters].first.should include :stdout
      end
    end

    context 'when a non-existent flag is specified' do
      let(:args) { ['--totally-made-up-flag'] }

      it 'raises an error' do
        expect { subject }.to raise_error SCSSLint::Exceptions::InvalidCLIOption
      end
    end

    context 'when a non-existent reporter is specified' do
      let(:args) { %w[--format NonExistentReporter] }

      it 'raises an error' do
        expect { subject }.to raise_error SCSSLint::Exceptions::InvalidCLIOption
      end
    end
  end
end
