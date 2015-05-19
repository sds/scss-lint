module SCSSLint
  class Plugins
    # Load ruby files from linter plugin directories
    class LinterDir
      attr_reader :config_options

      def initialize(dir)
        @dir = dir
        @config_options = {}
      end

      def load
        ruby_files.each { |file| require file }
        self
      end

    private

      attr_reader :dir

      def ruby_files
        Dir.glob(File.expand_path(File.join(dir, '/**/*.rb')))
      end
    end
  end
end
