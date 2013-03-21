require 'colorize'

module SCSSLint
  class Reporter::DefaultReporter < Reporter
    def report_lints
      if lints.any?
        lints.map do |lint|
          "#{lint.filename}:".yellow + "#{lint.line} - #{lint.description}"
        end.join("\n") + "\n"
      end
    end
  end
end
