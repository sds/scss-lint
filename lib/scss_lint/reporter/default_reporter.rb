module SCSSLint
  # Reports a single line per lint.
  class Reporter::DefaultReporter < Reporter
    def report_lints
      log_with_level "\n#{lints_run_count} scss lints, #{lints.size} errors\n"

      failure_messages
    end

  private

    def failure_messages
      return nil unless lints.any?

      lints.map do |lint|
        "#{location(lint)} #{type(lint)} #{message(lint)}"
      end.join("\n").concat("\n")
    end

    def location(lint)
      [
        log.cyan(lint.filename),
        log.magenta(lint.location.line.to_s),
        log.magenta(lint.location.column.to_s),
      ].join(':')
    end

    def type(lint)
      lint.error? ? log.red('[E]') : log.yellow('[W]')
    end

    def message(lint)
      linter_name = log.green("#{lint.linter.name}: ") if lint.linter
      "#{linter_name}#{lint.description}"
    end
  end
end
