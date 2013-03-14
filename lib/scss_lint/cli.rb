require 'scss_lint'
require 'optparse'

module SCSSLint
  class CLI
    attr_accessor :options

    def initialize(args)
      @options = {}
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: #{opts.program_name} [options] [scss-files]"

        opts.separator ''
        opts.separator 'Common options:'

        opts.on_tail('-h', '--help', 'Show this message') do
          options[:command] = [:print_help, opts.help]
        end

        opts.on_tail('-v', '--version', 'Show version') do
          options[:command] = [:print_version, opts.program_name, VERSION]
        end

        opts.on('-x', '--xml', 'Output the results in XML format') do
          options[:reporter] = SCSSLint::Reporter::XMLReporter
        end
      end

      begin
        parser.parse!(args)

        # Take the rest of the arguments as files/directories
        options[:files] = args
      rescue OptionParser::InvalidOption => ex
        options[:command] = [:print_help, parser.help, ex]
      end
    end

    def run
      if command = options[:command]
        send *command
      end

      files = SCSSLint.extract_files_from(options[:files])

      runner = Runner.new
      begin
        runner.run files
        report_lints(runner.lints)
        halt 1 if runner.lints?
      rescue NoFilesError => ex
        puts ex.message
        halt -1
      end
    end

  private

    def report_lints(lints)
      sorted_lints = lints.sort_by { |l| [l.filename, l.line] }
      reporter = options.fetch(:reporter, Reporter::DefaultReporter).new(sorted_lints)
      puts reporter.report_lints
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
