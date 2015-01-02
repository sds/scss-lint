module SCSSLint
  # Checks spacing of ! declarations, like !important and !default
  class Linter::BangFormat < Linter
    include LinterRegistry

    STOPPING_CHARACTERS = ['!', "'", '"', nil]

    def visit_prop(node)
      return unless node.to_sass.include?('!')
      return unless check_spacing(node)

      before_qualifier = config['space_before_bang'] ? '' : 'not '
      after_qualifier = config['space_after_bang'] ? '' : 'not '

      add_lint(node, "! should #{before_qualifier}be preceeded by a space, " \
                     "and should #{after_qualifier}be followed by a space")
    end

  private

    # Start from the back and move towards the front so that any !important or
    # !default !'s will be found *before* quotation marks. Then we can
    # stop at quotation marks to protect against linting !'s within strings
    # (e.g. `content`)
    def find_bang_offset(range)
      offset = 0
      offset -= 1 until STOPPING_CHARACTERS.include?(character_at(range.end_pos, offset))
      offset
    end

    def is_before_wrong?(range, offset)
      before_expected = config['space_before_bang'] ? / / : /[^ ]/
      before_actual = character_at(range.end_pos, offset - 1)
      (before_actual =~ before_expected).nil?
    end

    def is_after_wrong?(range, offset)
      after_expected = config['space_after_bang'] ? / / : /[^ ]/
      after_actual = character_at(range.end_pos, offset + 1)
      (after_actual =~ after_expected).nil?
    end

    def check_spacing(node)
      range = node.value_source_range
      offset = find_bang_offset(range)

      return if character_at(range.end_pos, offset) != '!'

      is_before_wrong?(range, offset) || is_after_wrong?(range, offset)
    end
  end
end
