require 'spec_helper'

describe SCSSLint::Plugins::LinterDir do
  let(:plugin_directory) { File.expand_path('../../fixtures/plugins', __FILE__) }
  let(:subject) { described_class.new(plugin_directory) }

  describe '#config_options' do
    it 'will return a Hash' do
      expect(subject.config_options).to be_instance_of Hash
    end

    it 'will be empty' do
      expect(subject.config_options.empty?).to be true
    end
  end

  describe '#load' do
    it 'will require each file in the dir' do
      subject.should_receive(:require)
        .with(File.join(plugin_directory, 'linter_plugin.rb')).once

      subject.load
    end
  end
end
