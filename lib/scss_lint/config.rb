require 'yaml'

module SCSSLint
  # Loads and manages application configuration.
  class Config
    DEFAULT_FILE = File.join(SCSS_LINT_HOME, 'config', 'default.yml')

    attr_reader :options, :warnings

    class << self
      def default
        @default ||= load(DEFAULT_FILE, merge_with_default: false)
      end

      # Loads a configuration from a file, merging it with the default
      # configuration.
      def load(file, merge_with_default: true)
        options = load_options_hash_from_file(file)

        if merge_with_default
          options = smart_merge(default_options_hash, options)
        end

        Config.new(options)
      end

    private

      def default_options_hash
        @default_options_hash ||= load_options_hash_from_file(DEFAULT_FILE)
      end

      # Recursively load config files, fetching files specified by `include`
      # directives and merging the file's config with the files specified.
      def load_options_hash_from_file(file)
        file_contents = load_file_contents(file)

        options =
          if file_contents.strip.empty?
            {}
          else
            YAML.load(file_contents).to_hash
          end

        if options['inherit_from']
          includes = [options.delete('inherit_from')].flatten.map do |include_file|
            load_options_hash_from_file(path_relative_to_config(include_file, file))
          end

          merged_includes = includes[1..-1].inject(includes.first) do |merged, include_file|
            smart_merge(merged, include_file)
          end

          options = smart_merge(merged_includes, options)
        end

        options
      end

      def path_relative_to_config(relative_include_path, base_config_path)
        if relative_include_path.start_with?('/')
          relative_include_path
        else
          File.join(File.dirname(base_config_path), relative_include_path)
        end
      end

      # For easy stubbing in tests
      def load_file_contents(file)
        File.open(file, 'r').read
      end

      # Merge two hashes, concatenating lists and further merging nested hashes.
      def smart_merge(parent, child)
        parent.merge(child) do |key, old, new|
          case old
          when Array
            old + new
          when Hash
            smart_merge(old, new)
          else
            new
          end
        end
      end
    end

    def initialize(options)
      @options = options
      @warnings = []

      validate_linters
    end

    def ==(other)
      super || @options == other.options
    end
    alias :eql? :==

    def linter_enabled?(linter)
      linter_options(linter)['enabled']
    end

    def linter_options(linter)
      @options['linters'][linter_name(linter)]
    end

  private

    def linter_name(linter)
      linter.class.name.split('::')[2..-1].join('::')
    end

    def validate_linters
      return unless linters = @options['linters']

      linters.keys.each do |name|
        begin
          Linter.const_get(name)
        rescue NameError
          @warnings << "Linter #{name} does not exist; ignoring"
        end
      end
    end
  end
end
