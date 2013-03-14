require 'scss_lint'
require 'optparse'

module SCSSLint
  class CLI
    def initialize(args)
      options = {}
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: #{opts.program_name} [options] [scss-files]"

        opts.separator ''
        opts.separator 'Common options:'

        opts.on_tail('-h', '--help', 'Show this message') do
          puts opts.help
          exit
        end

        opts.on_tail('-v', '--version', 'Show version') do
          puts "#{opts.program_name} #{VERSION}"
          exit
        end
      end

      begin
        parser.parse!(args)
      rescue OptionParser::InvalidOption => ex
        puts ex, ''
        puts parser.help
        exit
      end

      # Take the rest of the arguments as files/directories
      options[:files] = args

      run(options)
    end

  private

    def run(options)
      files = SCSSLint.extract_files_from(options[:files])

      runner = Runner.new
      begin
        runner.run files
        report_lints(runner.lints)
        exit 1 if runner.lints?
      rescue NoFilesError => ex
        puts ex.message
        exit -1
      end
    end

    def report_lints(lints)
      sorted_lints = lints.sort_by { |l| [l.filename, l.line] }
      puts Reporter::DefaultReporter.new(sorted_lints).report_lints
    end
  end
end
