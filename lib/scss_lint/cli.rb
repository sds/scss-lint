require 'find'
require 'optparse'

module SCSSLint
  # Responsible for parsing command-line options and executing the appropriate
  # application logic based on the options specified.
  class CLI
    attr_reader :config, :options

    def initialize(args = [])
      @args = args
      @options = {}
      @config = Config.default
    end

    def parse_arguments
      parser = OptionParser.new do |opts|
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

        opts.on('--xml', 'Output the results in XML format') do
          @options[:reporter] = SCSSLint::Reporter::XMLReporter
        end
      end

      begin
        parser.parse!(@args)

        # Take the rest of the arguments as files/directories
        @options[:files] = @args
      rescue OptionParser::InvalidOption => ex
        print_help parser.help, ex
      end

      begin
        setup_configuration
      rescue NoSuchLinter => ex
        puts ex.message
        halt(-1)
      end
    end

    def run
      runner = Runner.new(@config)
      runner.run(find_files)
      report_lints(runner.lints)
      halt(1) if runner.lints?
    rescue NoFilesError, NoSuchLinter, Errno::ENOENT => ex
      puts ex.message
      halt(-1)
    rescue => ex
      puts ex.message
      puts ex.backtrace
      puts 'Report this bug at '.yellow + BUG_REPORT_URL.cyan
      halt(-1)
    end

  private

    def setup_configuration
      @config = Config.load(@options[:config_file]) if @options[:config_file]

      if @options[:included_linters]
        @config.disable_all_linters
        LinterRegistry.extract_linters_from(@options[:included_linters]).each do |linter|
          @config.enable_linter(linter)
        end
      end

      if @options[:excluded_linters]
        LinterRegistry.extract_linters_from(@options[:excluded_linters]).each do |linter|
          @config.disable_linter(linter)
        end
      end
    end

    def find_files
      excluded_files = @options.fetch(:excluded_files, [])

      extract_files_from(@options[:files]).reject do |file|
        excluded_files.include?(file)
      end
    end

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
    def scssish_file?(file)
      return false unless FileTest.file?(file)

      VALID_EXTENSIONS.include?(File.extname(file))
    end

    def report_lints(lints)
      sorted_lints = lints.sort_by { |l| [l.filename, l.line] }
      reporter = @options.fetch(:reporter, Reporter::DefaultReporter)
                         .new(sorted_lints)
      output = reporter.report_lints
      print output if output
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

    def print_help(help_message, err = nil)
      puts err, '' if err
      puts help_message
      halt
    end

    def print_version(program_name, version)
      puts "#{program_name} #{version}"
      halt
    end

    # Used for ease-of testing
    def halt(exit_status = 0)
      exit exit_status
    end
  end
end
