module SCSSLint
  # Checks for space around operators on values.
  class Linter::SpaceAroundOperator < Linter
    include LinterRegistry

    def visit_script_operation(node)
      source = source_from_range(node.source_range)

      all_matches(source) do |match|
        if config['style'] == 'one_space'
          if match[:lspace] != ' ' || match[:rspace] != ' '
            add_lint(node, space_message(match))
          end
        elsif match[:lspace] != '' || match[:rspace] != ''
          add_lint(node, no_space_message(match))
        end
      end
    end

  private

    OPERATOR_REGEX = /
      \b
      (?<operation>
        (?<loperand>[^\s]+?)
        (?<lspace>\s*)
        (?<operator>
          (?:==|!=|>|>=|<|<=) |  # Comparison operators
          (?:[+\-*\/%])          # Mathematical operators
        )
        (?<rspace>\s*)
        (?<roperand>[^\s]+)
      )
      \b
    /ix

    # Finds all matches of OPERATOR_REGEX in a String. This method differs from
    # String#scan in that it will find intermediate matches that #scan
    # inherently walks past. For example:
    #
    #     all_matches("1 + 2 + 3 + 4 + 5")      #=> ["1 + 2", "2 + 3", "3 + 4", "4 + 5"]
    #     "1 + 2 + 3 + 4 + 5".scan(/\d \+ \d/)  #=> ["1 + 2", "3 + 4"]
    def all_matches(string)
      start = 0
      finish = string.length

      while start < finish
        match = string[start..-1].match(OPERATOR_REGEX)
        return if match.nil?

        yield match
        start += match.begin(:operator) + 1  # Move forward one character past the operator.
      end
    end

    def space_message(match)
      "`%s` should be written with a single space on each side of the operator: `%s %s %s`" %
        [match[:operation], match[:loperand], match[:operator], match[:roperand]]
    end

    def no_space_message(match)
      "`%s` should be written without spaces around the operator: `%s%s%s`" %
        [match[:operation], match[:loperand], match[:operator], match[:roperand]]
    end
  end
end
