module SCSSLint
  # Checks for unnecessary units on zero values.
  class Linter::ZeroUnit < Linter
    include LinterRegistry

    def visit_script_string(node)
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

    ZERO_UNIT_REGEX = /\b(0[a-z]+)\b/i

    MESSAGE_FORMAT = '`%s` should be written without units as `0`'

    def zero_with_units?(string)
      string =~ /^0[a-z]+/
    end
  end
end
