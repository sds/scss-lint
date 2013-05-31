RSpec::Matchers.define :report_lint do |options|
  options ||= {}
  expected_line = options[:line]

  match do |linter|
    has_lint?(linter, expected_line)
  end

  failure_message_for_should do |linter|
    'expected that a lint would be reported' +
      (expected_line ? " on line #{expected_line}" : '') +
      case linter.lints.count
      when 0
        ''
      when 1
        ", but was on line #{linter.lints.first.line}"
      else
        lines = lint_lines(linter)
        ", but lints were reported on lines #{lines[0...-1].join(', ')} and #{lines.last}"
      end
  end

  failure_message_for_should_not do |linter|
    'expected that a lint would not be reported'
  end

  description do
    'report a lint' + (expected_line ? " on line #{expected_line}" : '')
  end

  def has_lint?(linter, expected_line)
    if expected_line
      lint_lines(linter).include?(expected_line)
    else
      linter.lints.count == 1
    end
  end

  def lint_lines(linter)
    linter.lints.map(&:line)
  end
end
