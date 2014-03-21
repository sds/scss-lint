module SCSSLint
  # Checks for unnecessary leading zeros in numeric values with decimal points.
  class Linter::LeadingZero < Linter
    include LinterRegistry

    def visit_script_string(node)
      return unless node.type == :identifier

      non_string_values = remove_quoted_strings(node.value).split

      non_string_values.each do |value|
        if number = value[FRACTIONAL_DIGIT_REGEX, 1]
          check_number(node, number)
        end
      end
    end

    def visit_script_number(node)
      return unless number = source_from_range(node.source_range)[FRACTIONAL_DIGIT_REGEX, 1]

      check_number(node, number)
    end

  private

    FRACTIONAL_DIGIT_REGEX = /^-?(0?\.\d+)/

    CONVENTIONS = {
      'exclude_zero' => {
        explanation: '`%s` should be written without a leading zero as `%s`',
        validator: ->(original) { original =~ /^\.\d+$/ },
        converter: ->(original) { original[1..-1] },
      },
      'include_zero' => {
        explanation: '`%s` should be written with a leading zero as `%s`',
        validator: ->(original) { original =~ /^0\.\d+$/ },
        converter: ->(original) { "0#{original}" }
      },
    }

    def check_number(node, original_number)
      style = config.fetch('style', 'exclude_zero')
      convention = CONVENTIONS[style]

      unless convention[:validator].call(original_number)
        corrected = convention[:converter].call(original_number)

        add_lint(node, convention[:explanation] % [original_number, corrected])
      end
    end
  end
end
