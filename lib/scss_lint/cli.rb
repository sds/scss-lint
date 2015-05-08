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
      ok:             0,
      warning:        1,  # One or more warnings (but no errors) were reported
      error:          2,  # One or more errors were reported
      usage:          64, # Command line usage error
      no_input:       66, # Input file did not exist or was not readable
      unavailable:    69, # Required library is unavailable
      software:       70, # Internal software error
      config:         78, # Configuration error
      no_files:       80, # No files matched by specified glob patterns
      files_filtered: 81, # All matched files were filtered by exclusions
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
      runner.run(FileFinder.new(config).find(options[:files]))
      report_lints(options, runner.lints)

      if runner.lints.any?(&:error?)
        halt :error
      elsif runner.lints.any?
        halt :warning
      else
        halt :ok
      end
    end

    def handle_runtime_exception(exception) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/LineLength, Metrics/MethodLength
      case exception
      when SCSSLint::Exceptions::InvalidCLIOption
        puts exception.message
        puts 'Run `scss-lint --help` for usage documentation'
        halt :usage
      when SCSSLint::Exceptions::InvalidConfiguration
        puts exception.message
        halt :config
      when SCSSLint::Exceptions::RequiredLibraryMissingError
        puts exception.message
        halt :unavailable
      when SCSSLint::Exceptions::AllFilesFilteredError
        puts exception.message
        halt :files_filtered
      when SCSSLint::Exceptions::NoFilesError
        puts exception.message
        halt :no_files
      when Errno::ENOENT
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
          Config.load(options[:config_file])
        elsif File.exist?(Config::FILE_NAME)
          Config.load(Config::FILE_NAME)
        elsif File.exist?(Config::USER_FILE)
          Config.load(Config::USER_FILE)
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
    rescue LoadError => ex
      raise SCSSLint::Exceptions::RequiredLibraryMissingError,
            "Required library not found: #{ex.message}"
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
