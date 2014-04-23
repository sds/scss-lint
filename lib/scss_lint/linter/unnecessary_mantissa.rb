module SCSSLint
  # Checks for the unnecessary inclusion of a zero-value mantissa in numbers.
  # (e.g. `4.0` could be written as just `4`)
  class Linter::UnnecessaryMantissa < Linter
    include LinterRegistry

    def visit_script_string(node)
      return unless node.type == :identifier
      scan(node.value, node)
    end

    def visit_script_number(node)
      scan(source_from_range(node.source_range), node)
    end

  private

    REAL_NUMBER_REGEX = /
      \b(?<number>
        (?<integer>\d*)
        \.
        (?<mantissa>\d+)
        (?<units>\w*)
      )\b
    /ix

    MESSAGE_FORMAT = '`%s` should be written without the mantissa as `%s%s`'

    def scan(value, node)
      value.scan(REAL_NUMBER_REGEX) do |number, integer, mantissa, units|
        if unnecessary_mantissa?(mantissa)
          add_lint(node, format(MESSAGE_FORMAT, number, integer, units))
        end
      end
    end

    def unnecessary_mantissa?(mantissa)
      mantissa !~ /[^0]/
    end
  end
end
