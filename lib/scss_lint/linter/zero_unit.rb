module SCSSLint
  # Checks for unnecessary units on zero values.
  class Linter::ZeroUnit < Linter
    include LinterRegistry

    def visit_script_string(node)
      return unless node.type == :identifier

      node.value.scan(ZERO_UNIT_REGEX) do |match|
        add_lint(node, MESSAGE_FORMAT % match.first)
      end
    end

    def visit_script_number(node)
      length = source_from_range(node.source_range)[ZERO_UNIT_REGEX, 1]

      if node.value == 0 && zero_with_units?(length)
        add_lint(node, MESSAGE_FORMAT % length)
      end
    end

  private

    ZERO_UNIT_REGEX = %r{
      \b
      (?<!\.|\#)    # Ignore zeroes following `#` or `.` (colors / decimals)
      (0[a-z]+)     # Zero followed by letters (indicating some sort of unit)
      \b
    }ix

    MESSAGE_FORMAT = '`%s` should be written without units as `0`'

    def zero_with_units?(string)
      string =~ /^0[a-z]+/
    end
  end
end
