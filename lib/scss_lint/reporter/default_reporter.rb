require 'colorize'

module SCSSLint
  class Reporter::DefaultReporter < Reporter
    def report_lints
      lints.map do |lint|
        "#{lint.filename}:".yellow + "#{lint.line} - #{lint.description}"
      end.join("\n")
    end
  end
end
