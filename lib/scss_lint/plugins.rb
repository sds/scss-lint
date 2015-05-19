require_relative 'plugins/linter_gem'
require_relative 'plugins/linter_dir'

module SCSSLint
  # Loads plugin directories and gems
  class Plugins
    def initialize(config_options)
      @config_options = config_options
    end

    def load
      all.map(&:load)
    end

  private

    attr_reader :config_options

    def all
      [plugin_gems, plugin_directories].flatten
    end

    def plugin_gems
      config_options.fetch('plugin_gems', []).map do |gem_name|
        LinterGem.new(gem_name)
      end
    end

    def plugin_directories
      config_options.fetch('plugin_directories', []).map do |directory|
        LinterDir.new(directory)
      end
    end
  end
end
