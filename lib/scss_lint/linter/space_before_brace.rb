module SCSSLint
  # Checks for the presence of a single space before an opening brace.
  class Linter::SpaceBeforeBrace < Linter
    include LinterRegistry

    def check_node(node)
      source = source_from_range(node.source_range).strip

      # Only lint `@include`s which have curly braces
      if source[-1] == '{'
        check_for_space(node, source)
      end

      yield
    end

    alias_method :visit_function, :check_node
    alias_method :visit_each, :check_node
    alias_method :visit_for, :check_node
    alias_method :visit_function, :check_node
    alias_method :visit_mixindef, :check_node
    alias_method :visit_mixin, :check_node
    alias_method :visit_rule, :check_node
    alias_method :visit_while, :check_node

  private

    def check_for_space(node, string)
      line = node.source_range.end_pos.line
      char_before_is_whitespace = ["\n", ' '].include?(string[-2])

      if config['allow_single_line_padding'] && node_on_single_line?(node)
        unless char_before_is_whitespace
          add_lint(line, 'Opening curly brace `{` should be ' \
                         'preceded by at least one space')
        end
      else
        if !char_before_is_whitespace || string[-3] == ' '
          add_lint(line, 'Opening curly brace `{` should be ' \
                         'preceded by one space')
        end
      end
    end
  end
end
