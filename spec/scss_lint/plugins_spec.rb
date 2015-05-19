require 'spec_helper'

module SCSSLint
  describe Plugins do
    describe 'from_config_options' do
      let(:subject) { described_class.new(config_options) }

      describe 'load' do
        context 'with plugins' do
          let(:config_options) do
            { 'plugin_directories' => ['a_dir'],
              'plugin_gems' => ['a_gem'] }
          end

          context 'required successfully' do
            before do
              Plugins::LinterGem.any_instance.stub(:require).and_return true
              Plugins::LinterDir.any_instance.stub(:require).and_return true
            end

            it 'will return an Array' do
              expect(subject.load).to be_instance_of Array
            end

            it 'will contain 2 items' do
              expect(subject.load.count).to eq 2
            end
          end

          it 'will raise an exception if the gem is not required' do
            expect do
              subject.load
            end.to raise_exception Exceptions::PluginGemLoadError
          end
        end

        context 'without plugins' do
          let(:config_options) do
            { 'plugin_directories' => [],
              'plugin_gems' => [] }
          end

          it 'will return an Array' do
            expect(subject.load).to be_instance_of Array
          end

          it 'will be empty' do
            expect(subject.load.empty?).to be true
          end
        end

        context 'without config' do
          let(:config_options) { Hash.new }

          it 'will return an Array' do
            expect(subject.load).to be_instance_of Array
          end

          it 'will be empty' do
            expect(subject.load.empty?).to be true
          end
        end
      end
    end
  end
end
