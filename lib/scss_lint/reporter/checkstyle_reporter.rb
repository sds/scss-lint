module SCSSLint
  # Reports lints in a CheckStyle format.
  class Reporter::CheckStyleReporter < Reporter
    def report_lints
      output = '<?xml version="1.0" encoding="utf-8"?>'

      output << '<checkstyle version="1.5.6">'
      lints.group_by(&:filename).each do |filename, file_lints|
        output << "<file name=#{filename.encode(xml: :attr)}>"

        file_lints.each do |lint|
          output << issue_tag(lint)
        end

        output << '</file>'
      end
      output << '</checkstyle>'

      output
    end

  private

    def issue_tag(lint)
      "<error source=\"#{lint.linter.name if lint.linter}\" " \
             "line=\"#{lint.location.line}\" " \
             "column=\"#{lint.location.column}\" " \
             "length=\"#{lint.location.length}\" " \
             "severity=\"#{lint.severity}\" " \
             "message=#{lint.description.encode(xml: :attr)} />"
    end
  end
end
