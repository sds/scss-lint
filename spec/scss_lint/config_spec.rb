require 'spec_helper'
require 'fileutils'

describe SCSSLint::Config do
  class SCSSLint::Linter::FakeConfigLinter < SCSSLint::Linter; end

  module SCSSLint::Linter::SomeNamespace
    class FakeLinter1 < SCSSLint::Linter; end
    class FakeLinter2 < SCSSLint::Linter; end
  end

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

    context 'with a config file containing only comments' do
      let(:config_file) { '# This is a comment' }

      it 'returns the default configuration' do
        subject.should == described_class.default
      end
    end

    context 'with a file configuring an unknown linter' do
      let(:config_file) { 'linters: { MadeUpLinterName: { enabled: true } }' }

      it 'stores a warning for the unknown linter' do
        subject.warnings
               .any? { |warning| warning.include?('MadeUpLinterName') }
               .should be true
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

    context 'when a wildcard is used for a namespaced linter' do
      let(:default_file) { <<-FILE }
      linters:
        SomeNamespace::*:
          enabled: false
      FILE

      let(:config_file) { <<-FILE }
      linters:
        SomeNamespace::*:
          enabled: true
      FILE

      before do
        SCSSLint::LinterRegistry.stub(:linters)
          .and_return([SCSSLint::Linter::SomeNamespace::FakeLinter1,
                       SCSSLint::Linter::SomeNamespace::FakeLinter2])
      end

      it 'returns the same options for all linters under that namespace' do
        subject.linter_options(SCSSLint::Linter::SomeNamespace::FakeLinter1)
          .should eq('enabled' => true)
        subject.linter_options(SCSSLint::Linter::SomeNamespace::FakeLinter2)
          .should eq('enabled' => true)
      end
    end
  end

  describe '.for_file' do
    include_context 'isolated environment'

    let(:linted_file) { File.join('foo', 'bar', 'baz', 'file-being-linted.scss') }
    subject { described_class.for_file(linted_file) }

    before do
      described_class.instance_variable_set(:@dir_to_config, nil) # Clear cache
      FileUtils.mkpath(File.dirname(linted_file))
      FileUtils.touch(linted_file)
    end

    context 'when there are no configuration files in the directory hierarchy' do
      it { should be_nil }
    end

    context 'when there is a configuration file in the same directory' do
      let(:config_file) { File.join('foo', 'bar', 'baz', '.scss-lint.yml') }
      before { FileUtils.touch(config_file) }

      it 'loads that configuration file' do
        described_class.should_receive(:load).with(File.expand_path(config_file))
        subject
      end
    end

    context 'when there is a configuration file in the parent directory' do
      let(:config_file) { File.join('foo', 'bar', '.scss-lint.yml') }
      before { FileUtils.touch(config_file) }

      it 'loads that configuration file' do
        described_class.should_receive(:load).with(File.expand_path(config_file))
        subject
      end
    end

    context 'when there is a configuration file in some ancestor directory' do
      let(:config_file) { File.join('foo', '.scss-lint.yml') }
      before { FileUtils.touch(config_file) }

      it 'loads that configuration file' do
        described_class.should_receive(:load).with(File.expand_path(config_file))
        subject
      end
    end
  end

  describe '#linter_options' do
    let(:config) { described_class.new(options) }

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

    it 'returns the options for the specified linter' do
      config.linter_options(SCSSLint::Linter::FakeConfigLinter.new)
        .should == linter_options
    end
  end

  describe '#excluded_file?' do
    include_context 'isolated environment'

    let(:config_dir) { 'path/to' }
    let(:file_name) { "#{config_dir}/config.yml" }
    let(:config) { described_class.load(file_name) }

    before do
      described_class.stub(:load_file_contents)
                     .with(file_name)
                     .and_return(config_file)
    end

    context 'when no exclusion is specified' do
      let(:config_file) { 'linters: {}' }

      it 'does not exclude any files' do
        config.excluded_file?('anything/you/want.scss').should be false
      end
    end

    context 'when an exclusion is specified' do
      let(:config_file) { "exclude: 'foo/bar/baz/**'" }

      it 'does not exclude anything not matching the glob' do
        config.excluded_file?("#{config_dir}/foo/bar/something.scss").should be false
        config.excluded_file?("#{config_dir}/other/something.scss").should be false
      end

      it 'excludes anything matching the glob' do
        config.excluded_file?("#{config_dir}/foo/bar/baz/excluded.scss").should be true
        config.excluded_file?("#{config_dir}/foo/bar/baz/dir/excluded.scss").should be true
      end
    end
  end

  describe '#excluded_file_for_linter?' do
    include_context 'isolated environment'

    let(:config_dir) { 'path/to' }
    let(:file_name) { "#{config_dir}/config.yml" }
    let(:config) { described_class.load(file_name) }

    before do
      described_class.stub(:load_file_contents)
                     .with(file_name)
                     .and_return(config_file)
    end

    context 'when no exclusion is specified in linter' do
      let(:config_file) { <<-FILE }
      linters:
        FakeConfigLinter:
          enabled: true
      FILE

      it 'does not exclude any files' do
        config.excluded_file_for_linter?(
          "#{config_dir}/anything/you/want.scss",
          SCSSLint::Linter::FakeConfigLinter.new
        ).should == false
      end
    end

    context 'when an exclusion is specified in linter' do
      let(:config_file) { <<-FILE }
      linters:
        FakeConfigLinter:
          enabled: true
          exclude:
            - 'anything/you/want.scss'
      FILE

      it 'excludes file for the linter' do
        config.excluded_file_for_linter?(
          "#{config_dir}/anything/you/want.scss",
          SCSSLint::Linter::FakeConfigLinter.new
        ).should == true
      end
    end
  end
end
