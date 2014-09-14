module SCSSLint
  # Checks for a trailing semicolon on statements within rule sets.
  class Linter::TrailingSemicolon < Linter
    include LinterRegistry

    def visit_extend(node)
      check_semicolon(node)
    end

    def visit_variable(node)
      check_semicolon(node)
    end

    def visit_prop(node)
      if node.children.any? { |n| n.is_a?(Sass::Tree::PropNode) }
        yield # Continue checking children
      else
        check_semicolon(node)
      end
    end

    def visit_mixin(node)
      if node.children.any?
        yield # Continue checking children
      else
        check_semicolon(node)
      end
    end

  private

    def check_semicolon(node)
      if has_space_before_semicolon?(node)
        line = node.source_range.start_pos.line
        add_lint line, 'Declaration should be terminated by a semicolon'
      elsif !ends_with_semicolon?(node)
        line = node.source_range.start_pos.line
        add_lint line,
                 'Declaration should not have a space before ' \
                 'the terminating semicolon'
      elsif ends_with_multiple_semicolons?(node)
        line = node.source_range.start_pos.line
        add_lint line, 'Declaration should be terminated by a single semicolon'
      end
    end

    # Checks that the node is ended by a semicolon (with no whitespace)
    def ends_with_semicolon?(node)
      source_from_range(node.source_range) =~ /;$/
    end

    def ends_with_multiple_semicolons?(node)
      # Look one character past the end to see if there's another semicolon
      character_at(node.source_range.end_pos, 1) == ';'
    end

    def has_space_before_semicolon?(node)
      source_from_range(node.source_range) =~ /\s;$/
    end
  end
end
