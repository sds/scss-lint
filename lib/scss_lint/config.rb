require 'pathname'
require 'yaml'

module SCSSLint
  # Loads and manages application configuration.
  class Config
    FILE_NAME = '.scss-lint.yml'
    DEFAULT_FILE = File.join(SCSS_LINT_HOME, 'config', 'default.yml')

    attr_accessor :preferred # If this config should be preferred over others
    attr_reader :options, :warnings

    class << self
      def default
        load(DEFAULT_FILE, merge_with_default: false)
      end

      # Loads a configuration from a file, merging it with the default
      # configuration.
      def load(file, options = {})
        config_options = load_options_hash_from_file(file)

        if options.fetch(:merge_with_default, true)
          config_options = smart_merge(default_options_hash, config_options)
        end

        Config.new(config_options)
      end

      # Loads the configuration for a given file.
      def for_file(file_path)
        directory = File.dirname(File.expand_path(file_path))
        @dir_to_config ||= {}
        @dir_to_config[directory] ||=
          begin
            config_file = possible_config_files(directory).find { |path| path.file? }
            Config.load(config_file.to_s) if config_file
          end
      end

      def linter_name(linter)
        linter = linter.is_a?(Class) ? linter : linter.class
        linter.name.split('::')[2..-1].join('::')
      end

    private

      def possible_config_files(directory)
        files = Pathname.new(directory)
                        .enum_for(:ascend)
                        .map { |path| path + FILE_NAME }
        files << Pathname.new(FILE_NAME)
      end

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

        options = convert_single_options_to_arrays(options)
        options = extend_inherited_configs(options, file)
        options = merge_wildcard_linter_options(options)
        options = ensure_exclude_paths_are_absolute(options, file)
        options
      end

      # Convert any config options that accept a single value or an array to an
      # array form so that merging works.
      def convert_single_options_to_arrays(options)
        options = options.dup

        if options['exclude']
          # Ensure exclude is an array, since we allow user to specify a single
          # string. We do this before merging with the config loaded via
          # inherit_from since this allows us to merge the excludes from that,
          # rather than overwriting them.
          options['exclude'] = [options['exclude']].flatten
        end

        options
      end

      # Loads and extends a list of inherited options with the given options.
      def extend_inherited_configs(options, original_file)
        return options unless options['inherit_from']
        options = options.dup

        includes = [options.delete('inherit_from')].flatten.map do |include_file|
          load_options_hash_from_file(path_relative_to_config(include_file, original_file))
        end

        merged_includes = includes[1..-1].inject(includes.first) do |merged, include_file|
          smart_merge(merged, include_file)
        end

        smart_merge(merged_includes, options)
      end

      # Merge options from wildcard linters into individual linter configs
      def merge_wildcard_linter_options(options)
        options = options.dup

        options.fetch('linters', {}).keys.each do |class_name|
          next unless class_name.include?('*')

          class_name_regex = /#{class_name.gsub('*', '[^:]+')}/

          wildcard_options = options['linters'].delete(class_name)

          LinterRegistry.linters.each do |linter_class|
            name = linter_name(linter_class)

            if name.match(class_name_regex)
              old_options = options['linters'].fetch(name, {})
              options['linters'][name] = smart_merge(old_options, wildcard_options)
            end
          end
        end

        options
      end

      # Ensure all excludes are absolute paths
      def ensure_exclude_paths_are_absolute(options, original_file)
        options = options.dup

        if options['exclude']
          excludes = [options['exclude']].flatten

          options['exclude'] = excludes.map do |exclusion_glob|
            if exclusion_glob.start_with?('/')
              exclusion_glob
            else
              # Expand the path assuming it is relative to the config file itself
              File.expand_path(exclusion_glob, File.expand_path(File.dirname(original_file)))
            end
          end
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

    def enabled_linters
      LinterRegistry.extract_linters_from(@options['linters'].keys).select do |linter|
        linter_options(linter)['enabled']
      end
    end

    def linter_enabled?(linter)
      linter_options(linter)['enabled']
    end

    def enable_linter(linter)
      linter_options(linter)['enabled'] = true
    end

    def disable_linter(linter)
      linter_options(linter)['enabled'] = false
    end

    def disable_all_linters
      @options['linters'].values.each do |linter_config|
        linter_config['enabled'] = false
      end
    end

    def linter_options(linter)
      @options['linters'][self.class.linter_name(linter)]
    end

    def excluded_file?(file_path)
      abs_path = File.expand_path(file_path)

      @options.fetch('exclude', []).any? do |exclusion_glob|
        File.fnmatch(exclusion_glob, abs_path)
      end
    end

    def exclude_file(file_path)
      abs_path = File.expand_path(file_path)

      @options['exclude'] ||= []
      @options['exclude'] << abs_path
    end

  private

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
