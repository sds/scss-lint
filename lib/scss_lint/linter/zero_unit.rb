module SCSSLint
  # Checks for unnecessary units on zero values.
  class Linter::ZeroUnit < Linter
    include LinterRegistry

    def visit_script_string(node)
      node.value.scan(/\b(0[a-z]+)\b/i) do |match|
        add_lint(node, MESSAGE_FORMAT % match.first)
      end
    end

    def visit_script_number(node)
      if node.value == 0 && zero_with_units?(source_from_range(node.source_range))
        add_lint(node, MESSAGE_FORMAT % node.original_string)
      end
    end

  private

    MESSAGE_FORMAT = '`%s` should be written without units as `0`'

    def zero_with_units?(string)
      string =~ /^0[a-z]+/
    end
  end
end
