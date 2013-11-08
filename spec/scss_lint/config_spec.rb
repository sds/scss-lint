require 'spec_helper'

describe SCSSLint::Config do
  class SCSSLint::Linter::FakeConfigLinter < SCSSLint::Linter; end

  let(:default_file) { File.open(described_class::DEFAULT_FILE).read }

  # This complex stubbing bypasses the built-in caching of the methods, and at
  # the same time gives us full control over the "default" configuration.
  before do
    described_class
      .stub(:load_file_contents)
      .with(described_class::DEFAULT_FILE)
      .and_return(default_file)

    described_class
      .stub(:default_options_hash)
      .and_return(described_class.send(:load_options_hash_from_file, described_class::DEFAULT_FILE))

    described_class
      .stub(:default)
      .and_return(described_class.load(described_class::DEFAULT_FILE, merge_with_default: false))
  end

  describe '.default' do
    subject { described_class.default }

    it 'has a configuration defined for all registered linters' do
      SCSSLint::LinterRegistry.linters.map(&:new).each do |linter|
        subject.linter_options(linter).should_not be_nil
      end
    end
  end

  describe '.load' do
    let(:config_dir) { '/path/to' }
    let(:file_name) { "/#{config_dir}/config.yml" }

    let(:default_file) { <<-FILE }
    linters:
      FakeConfigLinter:
        enabled: true
      OtherFakeConfigLinter:
        enabled: false
    FILE

    subject { described_class.load(file_name) }

    before do
      described_class.stub(:load_file_contents)
                     .with(file_name)
                     .and_return(config_file)
    end

    context 'with an empty config file' do
      let(:config_file) { '' }

      it 'returns the default configuration' do
        subject.should == described_class.default
      end
    end

    context 'with a file configuring an unknown linter' do
      let(:config_file) { 'linters: { MadeUpLinterName: { enabled: true } }' }

      it 'stores a warning for the unknown linter' do
        subject.warnings
               .any? { |warning| warning.include?('MadeUpLinterName') }
               .should be_true
      end
    end

    context 'with a config file setting the same configuration as the default' do
      let(:config_file) { default_file }

      it 'returns a configuration equivalent to the default' do
        subject.should == described_class.default
      end
    end

    context 'with a config file setting the same subset of settings as the default' do
      let(:config_file) { <<-FILE }
      linters:
        FakeConfigLinter:
          enabled: true
      FILE

      it 'returns a configuration equivalent to the default' do
        subject.should == described_class.default
      end
    end

    context 'with a file that includes another configuration file' do
      let(:included_file_path) { '../included_file.yml' }

      let(:config_file) { <<-FILE }
      inherit_from: #{included_file_path}

      linters:
        FakeConfigLinter:
          enabled: true
          some_other_option: some_other_value
      FILE

      before do
        described_class.stub(:load_file_contents)
                       .with("#{config_dir}/" + included_file_path)
                       .and_return(included_file)
      end

      context 'and the included file has a different setting from the default' do
        let(:included_file) { <<-FILE }
          linters:
            OtherFakeConfigLinter:
              enabled: true
              some_option: some_value
        FILE

        it 'reflects the different setting of the included file' do
          subject.options['linters']['OtherFakeConfigLinter']
            .should == { 'enabled' => true, 'some_option' => 'some_value' }
        end

        it 'reflects the different setting of the file that included the file' do
          subject.options['linters']['FakeConfigLinter']
            .should == { 'enabled' => true, 'some_other_option' => 'some_other_value' }
        end
      end

      context 'and the included file has the same setting as the default' do
        let(:included_file) { <<-FILE }
          linters:
            OtherFakeConfigLinter:
              enabled: false
        FILE

        it 'does not alter the default configuration' do
          subject.options['linters']['OtherFakeConfigLinter']
            .should == { 'enabled' => false }
        end

        it 'reflects the different setting of the file that included the file' do
          subject.options['linters']['FakeConfigLinter']
            .should == { 'enabled' => true, 'some_other_option' => 'some_other_value' }
        end
      end

      context 'and the included file includes another file' do
        let(:other_included_file_path) { '/some/abs/other_included_file.yml' }

        let(:other_included_file) { <<-FILE }
          linters:
            OtherFakeConfigLinter:
              yet_another_option: yet_another_value
        FILE

        let(:included_file) { <<-FILE }
          inherit_from: #{other_included_file_path}

          linters:
            OtherFakeConfigLinter:
              enabled: true
              some_option: some_value
        FILE

        before do
          described_class.stub(:load_file_contents)
                         .with(other_included_file_path)
                         .and_return(other_included_file)
        end

        it "reflects the different setting of the included file's included file" do
          subject.options['linters']['OtherFakeConfigLinter']
            .should == {
              'enabled' => true,
              'some_option' => 'some_value',
              'yet_another_option' => 'yet_another_value',
            }
        end

        it 'reflects the different setting of the file that included the file' do
          subject.options['linters']['FakeConfigLinter']
            .should == { 'enabled' => true, 'some_other_option' => 'some_other_value' }
        end
      end
    end

    context 'with a file that includes multiple configuration files' do
      let(:included_file_path) { '../included_file.yml' }
      let(:other_included_file_path) { '/some/dir/other_included_file.yml' }

      let(:config_file) { <<-FILE }
      inherit_from:
        - #{included_file_path}
        - #{other_included_file_path}

      linters:
        FakeConfigLinter:
          enabled: true
          some_other_option: some_other_value
      FILE

      before do
        described_class.stub(:load_file_contents)
                       .with("#{config_dir}/" + included_file_path)
                       .and_return(included_file)

        described_class.stub(:load_file_contents)
                       .with(other_included_file_path)
                       .and_return(other_included_file)
      end

      context 'and the included files have settings different from each other' do
        let(:included_file) { <<-FILE }
          linters:
            OtherFakeConfigLinter:
              enabled: true
              some_option: earlier_value
              some_other_option: value
        FILE

        let(:other_included_file) { <<-FILE }
          linters:
            OtherFakeConfigLinter:
              enabled: true
              some_option: later_value
        FILE

        it 'uses the value of the file that was included last' do
          subject.options['linters']['OtherFakeConfigLinter']['some_option']
            .should == 'later_value'
        end

        it 'loads settings from both included files' do
          subject.options['linters']['OtherFakeConfigLinter']
            .should == {
              'enabled' => true,
              'some_option' => 'later_value',
              'some_other_option' => 'value',
            }
        end
      end
    end
  end

  describe '#linter_options' do
    let(:config) { described_class.new(options) }
    let(:linter) { SCSSLint::Linter::FakeConfigLinter.new }

    let(:linter_options) do
      {
        'enabled' => true,
        'some_option' => 'some_value',
      }
    end

    let(:options) do
      {
        'linters' => {
          'FakeConfigLinter' => linter_options
        }
      }
    end

    subject { config.linter_options(linter) }

    it 'returns the options for the specified linter' do
      subject.should == linter_options
    end
  end
end
