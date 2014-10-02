require 'json'

module SCSSLint
  # Reports lints in a JSON format.
  class Reporter::JSONReporter < Reporter
    def report_lints
      output = {}
      lints.group_by(&:filename).each do |filename, file_lints|
        output[filename] = file_lints.map do |lint|
          issue = {}
          issue['linter'] = lint.linter.name if lint.linter
          issue['line'] = lint.location.line
          issue['column'] = lint.location.column
          issue['length'] = lint.location.length
          issue['severity'] = lint.severity
          issue['reason'] = lint.description
          issue
        end
      end
      JSON.pretty_generate(output)
    end
  end
end
