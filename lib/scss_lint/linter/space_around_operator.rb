module SCSSLint
  # Checks for space around operators on values.
  class Linter::SpaceAroundOperator < Linter
    include LinterRegistry

    def visit_script_operation(node) # rubocop:disable Metrics/AbcSize
      source = source_from_range(node.source_range).chop
      left_range = node.operand1.source_range
      right_range = node.operand2.source_range

      # We need to #chop at the end because an operation's operand1 _always_
      # includes one character past the actual operand (which is either a
      # whitespace character, or the first character of the operation).
      left_source = source_from_range(left_range).chop
      right_source = source_from_range(right_range).chop
      operator_source = source_between(left_range, right_range)
      left_source, operator_source = adjust_left_boundary(left_source, operator_source)

      match = operator_source.match(/
        (?<left_space>\s*)
        (?<operator>\S+)
        (?<right_space>\s*)
      /x)

      if config['style'] == 'one_space'
        if match[:left_space] != ' ' || match[:right_space] != ' '
          add_lint(node, SPACE_MSG % [source, left_source, match[:operator], right_source])
        end
      elsif match[:left_space] != '' || match[:right_space] != ''
        add_lint(node, NO_SPACE_MSG % [source, left_source, match[:operator], right_source])
      end

      yield
    end

  private

    SPACE_MSG = '`%s` should be written with a single space on each side of ' \
                'the operator: `%s %s %s`'
    NO_SPACE_MSG = '`%s` should be written without spaces around the ' \
                   'operator: `%s%s%s`'

    def source_between(range1, range2)
      # We don't want to add 1 to range1.end_pos.offset for the same reason as
      # the #chop comment above.
      between_start = Sass::Source::Position.new(
        range1.end_pos.line,
        range1.end_pos.offset,
      )
      between_end = Sass::Source::Position.new(
        range2.start_pos.line,
        range2.start_pos.offset - 1,
      )

      source_from_range(Sass::Source::Range.new(between_start,
                                                between_end,
                                                range1.file,
                                                range1.importer))
    end

    def adjust_left_boundary(left, operator)
      # If the left operand is wrapped in parentheses, any right parens end up
      # in the operator source. Here, we move them into the left operand
      # source, which is awkward in any messaging, but it works.
      if match = operator.match(/^(\s*\))+/)
        left += match[0]
        operator = operator[match.end(0)..-1]
      end

      # If the left operand is a nested operation, Sass includes any whitespace
      # before the (outer) operator in the left operator's source_range's
      # end_pos, which is not the case with simple, non-operation operands.
      if match = left.match(/\s+$/)
        left = left[0..match.begin(0)]
        operator = match[0] + operator
      end

      [left, operator]
    end
  end
end
