require 'spec_helper'
require 'scss_lint/cli'

describe SCSSLint::CLI do
  let(:config_options) do
    {
      'linters' => {
        'FakeTestLinter1' => { 'enabled' => true },
        'FakeTestLinter2' => { 'enabled' => true },
      },
    }
  end

  let(:config) { SCSSLint::Config.new(config_options) }

  class SCSSLint::Linter::FakeTestLinter1 < SCSSLint::Linter; end
  class SCSSLint::Linter::FakeTestLinter2 < SCSSLint::Linter; end

  before do
    # Silence console output
    @output = ''
    STDOUT.stub(:write) { |*args| @output.<<(*args) }

    SCSSLint::Config.stub(:load).and_return(config)
    SCSSLint::LinterRegistry.stub(:linters)
                            .and_return([SCSSLint::Linter::FakeTestLinter1,
                                         SCSSLint::Linter::FakeTestLinter2])
  end

  describe '#run' do
    let(:files) { ['file1.scss', 'file2.scss'] }
    let(:flags) { [] }
    subject     { SCSSLint::CLI.new }

    before do
      SCSSLint::FileFinder.any_instance.stub(:find).and_return(files)
      SCSSLint::Runner.any_instance.stub(:find_lints)
    end

    def safe_run
      subject.run(flags + files)
    rescue SystemExit
      # Keep running tests
    end

    context 'when there are no lints' do
      before do
        SCSSLint::Runner.any_instance.stub(:lints).and_return([])
      end

      it 'returns a successful exit code' do
        safe_run.should == 0
      end

      it 'outputs nothing' do
        safe_run
        @output.should be_empty
      end
    end

    context 'when there are only warnings' do
      before do
        SCSSLint::Runner.any_instance.stub(:lints).and_return([
          SCSSLint::Lint.new(
            SCSSLint::Linter::FakeTestLinter1.new,
            'some-file.scss',
            SCSSLint::Location.new(1, 1, 1),
            'Some description',
            :warning,
          ),
        ])
      end

      it 'returns a exit code indicating only warnings were reported' do
        safe_run.should == 1
      end

      it 'outputs the warnings' do
        safe_run
        @output.should include 'Some description'
      end
    end

    context 'when there are errors' do
      before do
        SCSSLint::Runner.any_instance.stub(:lints).and_return([
          SCSSLint::Lint.new(
            SCSSLint::Linter::FakeTestLinter1.new,
            'some-file.scss',
            SCSSLint::Location.new(1, 1, 1),
            'Some description',
            :error,
          ),
        ])
      end

      it 'exits with an error status code' do
        safe_run.should == 2
      end

      it 'outputs the errors' do
        safe_run
        @output.should include 'Some description'
      end
    end

    context 'when the runner raises an error' do
      let(:backtrace) { %w[file1.rb file2.rb] }
      let(:message) { 'Some error message' }

      let(:error) do
        StandardError.new(message).tap { |e| e.set_backtrace(backtrace) }
      end

      before { SCSSLint::Runner.stub(:new).and_raise(error) }

      it 'exits with an internal software error status code' do
        subject.should_receive(:halt).with(:software)
        safe_run
      end

      it 'outputs the error message' do
        safe_run
        @output.should include message
      end

      it 'outputs the backtrace' do
        safe_run
        @output.should include backtrace.join("\n")
      end

      it 'outputs a link to the issue tracker' do
        safe_run
        @output.should include SCSSLint::BUG_REPORT_URL
      end
    end

    context 'when a required library is not found' do
      let(:flags) { ['--require', 'some_non_existent_library'] }

      before do
        Kernel.stub(:require).with('some_non_existent_library').and_raise(
          SCSSLint::Exceptions::RequiredLibraryMissingError
        )
      end

      it 'exits with an appropriate status code' do
        subject.should_receive(:halt).with(:unavailable)
        safe_run
      end
    end
  end
end
