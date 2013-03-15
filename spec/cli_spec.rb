require 'spec_helper'

describe SCSSLint::CLI do
  before do
    STDOUT.stub(:write) # Silence console output
  end

  describe '#parse_arguments' do
    let(:files)   { ['file1.scss', 'file2.scss'] }
    let(:options) { [] }
    subject       { SCSSLint::CLI.new(options + files) }

    def safe_parse
      subject.parse_arguments
    rescue SystemExit
      # Keep running tests
    end

    context 'when the excluded files flag is set' do
      let(:options) { ['-e', 'file1.scss,file3.scss'] }

      it 'sets the :excluded_files option' do
        safe_parse
        subject.options[:excluded_files].should =~ ['file1.scss', 'file3.scss']
      end
    end

    context 'when the ignore lints flag is set' do
      let(:options) { ['-i', 'some_linter_name'] }

      it 'sets the :ignored_linters option' do
        safe_parse
        subject.options[:ignored_linters].should == ['some_linter_name']
      end
    end

    context 'when the XML flag is set' do
      let(:options) { ['-x'] }

      it 'sets the :reporter option to the XML reporter' do
        safe_parse
        subject.options[:reporter].should == SCSSLint::Reporter::XMLReporter
      end
    end

    context 'when the help flag is set' do
      let(:options) { ['-h'] }

      it 'prints a help message' do
        subject.should_receive(:print_help)
        safe_parse
      end
    end

    context 'when the version flag is set' do
      let(:options) { ['-v'] }

      it 'prints the program version' do
        subject.should_receive(:print_version)
        safe_parse
      end
    end

    context 'when an invalid option is specified' do
      let(:options) { ['--non-existant-option'] }

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
    subject       { SCSSLint::CLI.new }

    before do
      subject.stub(:options).and_return(options)
      SCSSLint.stub(:extract_files_from).and_return(files)
    end

    def safe_run
      subject.run
    rescue SystemExit
      # Keep running tests
    end

    context 'when no files are specified' do
      let(:files) { [] }

      it 'exits with non-zero status' do
        subject.should_receive(:halt).with(-1)
        safe_run
      end
    end

    context 'when files are specified' do
      it 'passes the set of files to the runner' do
        SCSSLint::Runner.any_instance.should_receive(:run).with(files)
        safe_run
      end

      it 'uses the default reporter' do
        SCSSLint::Reporter::DefaultReporter.any_instance.
          should_receive(:report_lints)
        safe_run
      end
    end
  end
end
