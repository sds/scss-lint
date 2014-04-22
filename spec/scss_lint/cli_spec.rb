require 'spec_helper'

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

  describe '#parse_arguments' do
    let(:files)   { ['file1.scss', 'file2.scss'] }
    let(:flags) { [] }
    subject       { SCSSLint::CLI.new(flags + files) }

    def safe_parse
      subject.parse_arguments
    rescue SystemExit
      # Keep running tests
    end

    context 'when the config_file flag is set' do
      let(:config_file) { 'my-config-file.yml' }
      let(:flags) { ['-c', config_file] }

      it 'loads that config file' do
        SCSSLint::Config.should_receive(:load).with(config_file)
        safe_parse
      end

      context 'and the config file is invalid' do
        before do
          SCSSLint::Config.should_receive(:load)
                          .with(config_file)
                          .and_raise(SCSSLint::InvalidConfiguration)
        end

        it 'halts with a configuration error code' do
          subject.should_receive(:halt).with(:config)
          safe_parse
        end
      end
    end

    context 'when the excluded files flag is set' do
      let(:flags) { ['-e', 'file1.scss,file3.scss'] }

      it 'sets the :excluded_files option' do
        safe_parse
        subject.options[:excluded_files].should =~ ['file1.scss', 'file3.scss']
      end
    end

    context 'when the include linters flag is set' do
      let(:flags) { %w[-i FakeTestLinter2] }

      it 'enables only the included linters' do
        safe_parse
        subject.config.enabled_linters.should == [SCSSLint::Linter::FakeTestLinter2]
      end

      context 'and the included linter does not exist' do
        let(:flags) { %w[-i NonExistentLinter] }

        it 'halts with a configuration error code' do
          subject.should_receive(:halt).with(:config)
          safe_parse
        end
      end
    end

    context 'when the exclude linters flag is set' do
      let(:flags) { %w[-x FakeTestLinter1] }

      it 'includes all linters except the excluded one' do
        safe_parse
        subject.config.enabled_linters.should == [SCSSLint::Linter::FakeTestLinter2]
      end
    end

    context 'when the format flag is set' do
      context 'and the format is valid' do
        let(:flags) { %w[--format XML] }

        it 'sets the :reporter option to the correct reporter' do
          safe_parse
          subject.options[:reporter].should == SCSSLint::Reporter::XMLReporter
        end
      end

      context 'and the format is invalid' do
        let(:flags) { %w[--format InvalidFormat] }

        it 'sets the :reporter option to the correct reporter' do
          subject.should_receive(:halt).with(:config)
          safe_parse
        end
      end
    end

    context 'when the show linters flag is set' do
      let(:flags) { ['--show-linters'] }

      it 'prints the linters' do
        subject.should_receive(:print_linters)
        safe_parse
      end
    end

    context 'when the help flag is set' do
      let(:flags) { ['-h'] }

      it 'prints a help message' do
        subject.should_receive(:print_help)
        safe_parse
      end
    end

    context 'when the version flag is set' do
      let(:flags) { ['-v'] }

      it 'prints the program version' do
        subject.should_receive(:print_version)
        safe_parse
      end
    end

    context 'when an invalid option is specified' do
      let(:flags) { ['--non-existant-option'] }

      it 'prints a help message' do
        subject.should_receive(:print_help)
        safe_parse
      end
    end

    context 'when no files are specified' do
      let(:files) { [] }

      it 'sets :files option to the empty list' do
        safe_parse
        subject.options[:files].should be_empty
      end
    end

    context 'when files are specified' do
      it 'sets :files option to the list of files' do
        safe_parse
        subject.options[:files].should =~ files
      end
    end
  end

  describe '#run' do
    let(:files)   { ['file1.scss', 'file2.scss'] }
    let(:options) { {} }
    subject       { SCSSLint::CLI.new(options) }

    before do
      subject.stub(:extract_files_from).and_return(files)
    end

    def safe_run
      subject.run
    rescue SystemExit
      # Keep running tests
    end

    context 'when no files are specified' do
      let(:files) { [] }

      it 'exits with a no-input status code' do
        subject.should_receive(:halt).with(:no_input)
        safe_run
      end
    end

    context 'when files are specified' do
      it 'passes the set of files to the runner' do
        SCSSLint::Runner.any_instance.should_receive(:run).with(files)
        safe_run
      end

      it 'uses the default reporter' do
        SCSSLint::Reporter::DefaultReporter.any_instance
          .should_receive(:report_lints)
        safe_run
      end
    end

    context 'when there are no lints' do
      before do
        SCSSLint::Runner.any_instance.stub(:lints).and_return([])
      end

      it 'exits cleanly' do
        subject.should_not_receive(:halt)
        safe_run
      end

      it 'outputs nothing' do
        safe_run
        @output.should be_empty
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
  end
end
