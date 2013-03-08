require 'scss_lint'
require 'colorize'
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

        opts.on("-x", "--lintxml", "Outputs the results in Lint XML format") do |v|
          options[:xml] = true
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

    def xml_output(lints)
      prev_filename = nil
      res = '<?xml version="1.0" encoding="utf-8"?><lint>'
      lints.sort_by { |l| [l.filename, l.line] }.each do |lint|
        if lint.filename != prev_filename
          if not prev_filename.nil?
            res << '</file>'
          end
          res << "<file name='#{lint.filename}'>"
          prev_filename = lint.filename
        end
        res << "<issue line='#{lint.line}' severity='warning' reason='#{lint.description}' />"
      end
      res << '</file></lint>'
      res
    end

    def report_lints(lints, options)
      if options[:xml]
        puts xml_output(lints)
      else
        lints.sort_by { |l| [l.filename, l.line] }.each do |lint|
          if lint.filename
            print "#{lint.filename}:".yellow
          else
            print 'line'.yellow
          end
          puts "#{lint.line} - #{lint.description}"
        end
      end
    end

  private

    def run(options)
      files = SCSSLint.extract_files_from(options[:files])

      runner = Runner.new
      begin
        runner.run files
        report_lints(runner.lints, options)
      rescue NoFilesError => ex
        puts ex.message
        exit -1
      end
    end
  end
end
