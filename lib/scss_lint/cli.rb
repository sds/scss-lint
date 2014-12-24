require 'find'
require 'rainbow'
require 'rainbow/ext/string'
require 'scss_lint/options'

module SCSSLint
  # Responsible for parsing command-line options and executing the appropriate
  # application logic based on the options specified.
  class CLI
    attr_reader :config, :options

    # Subset of semantic exit codes conforming to `sysexits` documentation.
    EXIT_CODES = {
      ok:        0,
      warning:   1,  # One or more warnings (but no errors) were reported
      error:     2,  # One or more errors were reported
      usage:     64, # Command line usage error
      no_input:  66, # Input file did not exist or was not readable
      software:  70, # Internal software error
      config:    78, # Configuration error
    }

    def run(args)
      options = SCSSLint::Options.new.parse(args)
      act_on_options(options)
    rescue => ex
      handle_runtime_exception(ex)
    end

  private

    def act_on_options(options)
      load_required_paths(options)
      load_reporters(options)

      if options[:help]
        print_help(options)
      elsif options[:version]
        print_version
      elsif options[:show_linters]
        print_linters
      elsif options[:show_formatters]
        print_formatters
      else
        config = setup_configuration(options)
        scan_for_lints(options, config)
      end
    end

    def scan_for_lints(options, config)
      runner = Runner.new(config)
      runner.run(files_to_lint(options, config))
      report_lints(options, runner.lints)

      if runner.lints.any?(&:error?)
        halt :error
      elsif runner.lints.any?
        halt :warning
      else
        halt :ok
      end
    end

    def handle_runtime_exception(exception) # rubocop:disable Metrics/AbcSize
      case exception
      when SCSSLint::Exceptions::InvalidCLIOption
        puts exception.message
        puts 'Run `scss-lint --help` for usage documentation'
        halt :usage
      when SCSSLint::Exceptions::InvalidConfiguration
        puts exception.message
        halt :config
      when NoFilesError, Errno::ENOENT
        puts exception.message
        halt :no_input
      when NoSuchLinter
        puts exception.message
        halt :usage
      else
        puts exception.message
        puts exception.backtrace
        puts 'Report this bug at '.color(:yellow) + BUG_REPORT_URL.color(:cyan)
        halt :software
      end
    end

    def setup_configuration(options)
      config =
        if options[:config_file]
          Config.load(options[:config_file]).tap do |conf|
            conf.preferred = true
          end
        else
          Config.default
        end

      merge_options_with_config(options, config)
    end

    # @param options [Hash]
    # @param config [Config]
    # @return [Config]
    def merge_options_with_config(options, config)
      if options[:excluded_files]
        options[:excluded_files].each do |file|
          config.exclude_file(file)
        end
      end

      if options[:included_linters]
        config.disable_all_linters
        LinterRegistry.extract_linters_from(options[:included_linters]).each do |linter|
          config.enable_linter(linter)
        end
      end

      if options[:excluded_linters]
        LinterRegistry.extract_linters_from(options[:excluded_linters]).each do |linter|
          config.disable_linter(linter)
        end
      end

      config
    end

    def files_to_lint(options, config)
      if options[:files].empty?
        options[:files] = config.scss_files
      end

      extract_files_from(options[:files]).reject do |file|
        actual_config =
          if !config.preferred && (config_for_file = Config.for_file(file))
            merge_options_with_config(options, config_for_file.dup)
          else
            config
          end

        actual_config.excluded_file?(file)
      end
    end

    # @param list [Array]
    def extract_files_from(list)
      files = []
      list.each do |file|
        Find.find(file) do |f|
          files << f if scssish_file?(f)
        end
      end
      files.uniq
    end

    VALID_EXTENSIONS = %w[.css .scss]
    # @param file [String]
    # @return [Boolean]
    def scssish_file?(file)
      return false unless FileTest.file?(file)

      VALID_EXTENSIONS.include?(File.extname(file))
    end

    # @param options [Hash]
    # @param lints [Array<Lint>]
    def report_lints(options, lints)
      sorted_lints = lints.sort_by { |l| [l.filename, l.location] }
      options.fetch(:reporters).each do |reporter, output|
        results = reporter.new(sorted_lints).report_lints
        io = (output == :stdout ? $stdout : File.new(output, 'w+'))
        io.print results if results
      end
    end

    def load_required_paths(options)
      Array(options[:required_paths]).each do |path|
        require path
      end
    end

    def load_reporters(options)
      options[:reporters].map! do |reporter_name, output_file|
        begin
          reporter = SCSSLint::Reporter.const_get(reporter_name + 'Reporter')
        rescue NameError
          raise SCSSLint::Exceptions::InvalidCLIOption,
                "Invalid output format specified: #{reporter_name}"
        end
        [reporter, output_file]
      end
    end

    def print_formatters
      puts 'Installed formatters:'

      reporter_names = SCSSLint::Reporter.descendants.map do |reporter|
        reporter.name.split('::').last.split('Reporter').first
      end

      reporter_names.sort.each do |reporter_name|
        puts " - #{reporter_name}"
      end

      halt
    end

    def print_linters
      puts 'Installed linters:'

      linter_names = LinterRegistry.linters.map do |linter|
        linter.name.split('::').last
      end

      linter_names.sort.each do |linter_name|
        puts " - #{linter_name}"
      end

      halt
    end

    # @param options [Hash]
    def print_help(options)
      puts options[:help]
      halt :ok
    end

    # @param options [Hash]
    def print_version
      puts "scss-lint #{SCSSLint::VERSION}"
      halt :ok
    end

    # Used for ease-of testing
    # @param exit_status [Symbol]
    def halt(exit_status = :ok)
      EXIT_CODES[exit_status]
    end
  end
end
