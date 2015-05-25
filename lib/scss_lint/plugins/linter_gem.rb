module SCSSLint
  class Plugins
    # Load linter plugin gems
    class LinterGem
      def initialize(name)
        @name = name
      end

      def load
        require name
        self
      rescue LoadError
        raise_error
      end

      def config_options
        if File.exist?(config_file)
          load_config_from_file(config_file)
        else
          {}
        end
      end

    private

      attr_reader :name

      def load_config_from_file(config_file)
        Config.send(:load_options_hash_from_file, config_file)
      end

      def config_file
        File.join(gem_dir, Config::FILE_NAME)
      end

      def gem_specification
        Gem::Specification.find_by_name(name)
      rescue Gem::LoadError
        raise_error
      end

      def gem_dir
        gem_specification.gem_dir
      end

      def raise_error
        raise SCSSLint::Exceptions::PluginGemLoadError,
              "Unable to load linter plugin gem '#{name}' as it's not " \
              'part of the bundle, linter_plugin_gems are specified in ' \
              "your scss_lint.yml configuration. Try running 'gem install " \
              "#{name}'"
      end
    end
  end
end
