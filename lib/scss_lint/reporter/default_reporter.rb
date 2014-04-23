module SCSSLint
  # Reports a single line per lint.
  class Reporter::DefaultReporter < Reporter
    def report_lints
      return unless lints.any?

      lints.map do |lint|
        type = lint.error? ? '[E]'.color(:red) : '[W]'.color(:yellow)
        "#{lint.filename.color(:cyan)}:" << "#{lint.location.line}".color(:magenta) <<
                                    " #{type} #{lint.description}"
      end.join("\n") + "\n"
    end
  end
end
