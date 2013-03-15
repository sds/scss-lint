require 'spec_helper'

describe SCSSLint::CLI do
  let(:files)   { ['file1.scss', 'file2.scss'] }
  let(:options) { [] }
  subject       { SCSSLint::CLI.new(options + files) }

  before do
    STDOUT.stub(:write) # Silence console output
  end

  describe '#new' do
    it 'sets options[:files] with the list of files' do
      subject.options[:files].should =~ files
    end

    context 'when the ignore lints flag is set' do
      let(:options) { ['-i', 'some_linter_name'] }

      it 'passes in the :ignored_linters option to the runner' do
        subject.options[:ignored_linters].should == ['some_linter_name']
      end
    end
  end

  describe '#run' do
    before do
      SCSSLint.stub(:extract_files_from).and_return(files)
    end

    def safe_run
      subject.run
    rescue SystemExit
      # Keep running tests
    end

    context 'when the excluded files flag is set' do
      let(:options) { ['-e', 'file1.scss,file3.scss'] }

      it 'does not lint those files' do
        SCSSLint::Runner.any_instance.should_receive(:run).with(['file2.scss'])
        safe_run
      end
    end

    context 'when the help flag is set' do
      let(:options) { ['-h'] }

      it 'prints a help message' do
        subject.should_receive(:print_help)
        safe_run
      end
    end

    context 'when the version flag is set' do
      let(:options) { ['-v'] }

      it 'prints the program version' do
        subject.should_receive(:print_version)
        safe_run
      end
    end

    context 'when the XML flag is set' do
      let(:options) { ['-x'] }

      it 'uses the XML reporter' do
        SCSSLint::Reporter::XMLReporter.any_instance.should_receive(:report_lints)
        safe_run
      end
    end

    context 'when an invalid option is specified' do
      let(:options) { ['--non-existant-option'] }

      it 'prints a help message' do
        subject.should_receive(:print_help)
        safe_run
      end
    end

    context 'when no files are specified' do
      let(:files) { [] }

      it 'exits with non-zero status' do
        subject.should_receive(:halt).with(-1)
        safe_run
      end
    end

    context 'when files are specified' do
      it 'uses the default reporter' do
        SCSSLint::Reporter::DefaultReporter.any_instance.
          should_receive(:report_lints)
        safe_run
      end
    end
  end
end
