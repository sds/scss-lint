module SCSSLint
  # Checks for unnecessary leading zeros in numeric values with decimal points.
  class Linter::LeadingZero < Linter
    include LinterRegistry

    def visit_script_string(node)
      return unless node.type == :identifier

      non_string_values = remove_quoted_strings(node.value).split

      non_string_values.each do |value|
        if number = value[/\b(0\.\d+)/, 1]
          add_leading_zero_lint(node, number)
        end
      end
    end

    def visit_script_number(node)
      return unless original_number = source_from_range(node.source_range)[/\b(0.\d+)/, 1]

      add_leading_zero_lint(node, original_number)
    end

  private

    def add_leading_zero_lint(node, number)
      trimmed_number = number[/^[^\.]+(.*)$/, 1]

      add_lint(node, "`#{number}` should be written without a leading zero " <<
                     "as `#{trimmed_number}`")
    end
  end
end
