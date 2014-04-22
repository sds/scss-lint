require 'find'
require 'optparse'
require 'rainbow'
require 'rainbow/ext/string'

module SCSSLint
  # Responsible for parsing command-line options and executing the appropriate
  # application logic based on the options specified.
  class CLI
    attr_reader :config, :options

    # Subset of semantic exit codes conforming to `sysexits` documentation.
    EXIT_CODES = {
      ok:        0,
      usage:     64, # Command line usage error
      data:      65, # User input was incorrect (i.e. contains lints)
      no_input:  66, # Input file did not exist or was not readable
      software:  70, # Internal software error
      config:    78, # Configuration error
    }

    # @param args [Array]
    def initialize(args = [])
      @args    = args
      @options = {}
      @config  = Config.default
    end

    def parse_arguments
      begin
        options_parser.parse!(@args)

        # Take the rest of the arguments as files/directories
        @options[:files] = @args
      rescue OptionParser::InvalidOption => ex
        print_help options_parser.help, ex
      end

      begin
        setup_configuration
      rescue InvalidConfiguration, NoSuchLinter => ex
        puts ex.message
        halt :config
      end
    end

    # @return [OptionParser]
    def options_parser
      @options_parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: #{opts.program_name} [options] [scss-files]"

        opts.separator ''
        opts.separator 'Common options:'

        opts.on('-c', '--config file', 'Specify configuration file', String) do |file|
          @options[:config_file] = file
        end

        opts.on('-e', '--exclude file,...', Array,
                'List of file names to exclude') do |files|
          @options[:excluded_files] = files
        end

        opts.on('-f', '--format Formatter', 'Specify how to display lints', String) do |format|
          define_output_format(format)
        end

        opts.on('-i', '--include-linter linter,...', Array,
                'Specify which linters you want to run') do |linters|
          @options[:included_linters] = linters
        end

        opts.on('-x', '--exclude-linter linter,...', Array,
                "Specify which linters you don't want to run") do |linters|
          @options[:excluded_linters] = linters
        end

        opts.on_tail('--show-linters', 'Shows available linters') do
          print_linters
        end

        opts.on_tail('-h', '--help', 'Show this message') do
          print_help opts.help
        end

        opts.on_tail('-v', '--version', 'Show version') do
          print_version opts.program_name, VERSION
        end
      end
    end

    def run
      runner = Runner.new(@config)
      runner.run(files_to_lint)
      report_lints(runner.lints)
      halt :data if runner.lints.any?
    rescue InvalidConfiguration => ex
      puts ex
      halt :config
    rescue NoFilesError, Errno::ENOENT => ex
      puts ex.message
      halt :no_input
    rescue NoSuchLinter => ex
      puts ex.message
      halt :usage
    rescue => ex
      puts ex.message
      puts ex.backtrace
      puts 'Report this bug at '.color(:yellow) + BUG_REPORT_URL.color(:cyan)
      halt :software
    end

  private

    def setup_configuration
      if @options[:config_file]
        @config = Config.load(@options[:config_file])
        @config.preferred = true
      end

      merge_command_line_flags_with_config(@config)
    end

    # @param config [Config]
    # @return [Config]
    def merge_command_line_flags_with_config(config)
      if @options[:excluded_files]
        @options[:excluded_files].each do |file|
          config.exclude_file(file)
        end
      end

      if @options[:included_linters]
        config.disable_all_linters
        LinterRegistry.extract_linters_from(@options[:included_linters]).each do |linter|
          config.enable_linter(linter)
        end
      end

      if @options[:excluded_linters]
        LinterRegistry.extract_linters_from(@options[:excluded_linters]).each do |linter|
          config.disable_linter(linter)
        end
      end

      config
    end

    def files_to_lint
      extract_files_from(@options[:files]).reject do |file|
        config =
          if !@config.preferred && (config_for_file = Config.for_file(file))
            merge_command_line_flags_with_config(config_for_file.dup)
          else
            @config
          end

        config.excluded_file?(file)
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

    # @param lints [Array<Lint>]
    def report_lints(lints)
      sorted_lints = lints.sort_by { |l| [l.filename, l.location] }
      reporter = @options.fetch(:reporter, Reporter::DefaultReporter)
                         .new(sorted_lints)
      output = reporter.report_lints
      print output if output
    end

    # @param format [String]
    def define_output_format(format)
      @options[:reporter] = SCSSLint::Reporter.const_get(format + 'Reporter')
    rescue NameError
      puts "Invalid output format specified: #{format}"
      halt :config
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

    # @param help_message [String]
    # @param err [Exception]
    def print_help(help_message, err = nil)
      puts err, '' if err
      puts help_message
      halt(err ? :usage : :ok)
    end

    # @param program_name [String]
    # @param version [String]
    def print_version(program_name, version)
      puts "#{program_name} #{version}"
      halt
    end

    # Used for ease-of testing
    # @param exit_status [Symbol]
    def halt(exit_status = :ok)
      exit(EXIT_CODES[exit_status])
    end
  end
end
