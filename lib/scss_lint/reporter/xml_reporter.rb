module SCSSLint
  # Reports lints in an XML format.
  class Reporter::XMLReporter < Reporter
    def report_lints
      output = '<?xml version="1.0" encoding="utf-8"?>'

      output << '<lint>'
      lints.group_by(&:filename).each do |filename, file_lints|
        output << "<file name='#{filename}'>"

        file_lints.each do |lint|
          output << "<issue line='#{lint.line}' " <<
                           "severity='#{lint.severity}' " <<
                           "reason='#{lint.description}' />"
        end

        output << '</file>'
      end
      output << '</lint>'

      output
    end
  end
end
