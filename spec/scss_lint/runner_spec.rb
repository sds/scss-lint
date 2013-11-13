require 'spec_helper'

describe SCSSLint::Runner do
  let(:config) { SCSSLint::Config.default.dup }
  let(:runner) { SCSSLint::Runner.new(config) }

  before do
    SCSSLint::LinterRegistry.stub(:linters)
                            .and_return([SCSSLint::Linter::FakeLinter1,
                                         SCSSLint::Linter::FakeLinter2])
    SCSSLint::Config.stub(:for_file)
  end

  class SCSSLint::Linter::FakeLinter1 < SCSSLint::Linter; end
  class SCSSLint::Linter::FakeLinter2 < SCSSLint::Linter; end

  describe '#run' do
    let(:files) { ['dummy1.scss', 'dummy2.scss'] }
    subject     { runner.run(files) }
    before      { SCSSLint::Engine.stub(:new) }

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

    context 'when no linters are enabled' do
      before { config.stub(:enabled_linters) { [] } }

      it 'raises an error' do
        expect { subject }.to raise_error
      end
    end

    context 'when a linter raises an error' do
      let(:backtrace) { %w[file.rb:1 file.rb:2] }

      let(:error) do
        StandardError.new('Some error message').tap do |e|
          e.set_backtrace(backtrace)
        end
      end

      before do
        SCSSLint::Linter::FakeLinter1.any_instance.stub(:run).and_raise(error)
      end

      it 'raises a LinterError' do
        expect { subject }.to raise_error(SCSSLint::LinterError)
      end

      it 'has the name of the file the linter was checking' do
        expect { subject }.to raise_error { |e| e.message.should include files.first }
      end

      it 'has the same backtrace as the original error' do
        expect { subject }.to raise_error { |e| e.backtrace.should == backtrace }
      end
    end
  end
end
