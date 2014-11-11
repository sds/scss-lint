module SCSSLint
  # Reports a single line per lint.
  class Reporter::DefaultReporter < Reporter
    def report_lints
      return unless lints.any?

      lints.map do |lint|
        "#{location(lint)} #{type(lint)} #{message(lint)}"
      end.join("\n") + "\n"
    end

  private

    def location(lint)
      "#{lint.filename.color(:cyan)}:#{lint.location.line.to_s.color(:magenta)}"
    end

    def type(lint)
      lint.error? ? '[E]'.color(:red) : '[W]'.color(:yellow)
    end

    def message(lint)
      linter_name = "#{lint.linter.name}: ".color(:green) if lint.linter
      "#{linter_name}#{lint.description}"
    end
  end
end
