require 'scss_lint'
require 'colorize'
require 'optparse'

module SCSSLint
  class CLI
    def initialize(args)
      opts = OptionParser.new do |opts|
        opts.banner = 'Usage: scss-lint [scss-files]'
      end.parse!(args)

      files = SCSSLint.extract_files_from(opts)

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
end
