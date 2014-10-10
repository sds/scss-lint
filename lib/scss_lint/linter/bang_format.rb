module SCSSLint
  # Checks spacing of ! declarations, like !important and !default
  class Linter::BangFormat < Linter
    include LinterRegistry

    def visit_prop(node)
      return unless node.to_sass.include? '!'
      return unless check_spacing(node)
      before_qualifier = config['space_before_bang'] ? '' : 'not '
      after_qualifier = config['space_after_bang'] ? '' : 'not '
      message = "! should #{before_qualifier}be preceeded by a space, " \
              "and should #{after_qualifier}be followed by a space"
      add_lint(node, message)
    end

  private

    def find_bang_offset(range)
      offset = 0
      offset += 1 while character_at(range.start_pos, offset) != '!'
      offset
    end

    def check_spacing(node)
      range = node.value_source_range
      offset = find_bang_offset(range)

      before_expected = config['space_before_bang'] ? / / : /[^ ]/
      before_actual = character_at(range.start_pos, offset - 1)
      before_is_wrong = (before_actual =~ before_expected).nil?

      after_expected = config['space_after_bang'] ? / / : /[^ ]/
      after_actual = character_at(range.start_pos, offset + 1)
      after_is_wrong = (after_actual =~ after_expected).nil?

      before_is_wrong || after_is_wrong
    end
  end
end
