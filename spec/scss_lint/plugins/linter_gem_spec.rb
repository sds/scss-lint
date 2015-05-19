require 'spec_helper'

module SCSSLint
  describe Plugins::LinterGem do
    let(:subject) { described_class.new('a_gem') }

    describe '#load' do
      it 'will raise an exception if the gem is not installed' do
        expect do
          subject.load
        end.to raise_exception Exceptions::PluginGemLoadError
      end

      it 'will require the gem' do
        subject.should_receive(:require).with('a_gem').once
        subject.load
      end
    end

    describe '#config_options' do
      it 'will raise an exception if the gem is not installed' do
        expect do
          subject.config_options
        end.to raise_exception Exceptions::PluginGemLoadError
      end

      context 'gem loaded' do
        before do
          described_class.any_instance.stub(:require).and_return true
          subject.stub(:gem_dir).and_return '/dir'
        end

        context 'with config file' do
          it 'will load the config' do
            File.stub(:exist?).and_return true
            subject.should_receive(:load_config_from_file)
                  .with('/dir/.scss-lint.yml').and_return({})

            subject.config_options
          end
        end

        context 'no config file' do
          it 'will return an empty hash' do
            expect(subject.config_options).to be_a Hash
            expect(subject.config_options.empty?).to be true
          end
        end
      end
    end
  end
end
