module SCSSLint
  # Checks for a trailing semicolon on statements within rule sets.
  class Linter::TrailingSemicolon < Linter
    include LinterRegistry

    def visit_prop(node)
      if has_nested_properties?(node)
        yield # Continue checking children
      else
        check_semicolon(node)
      end
    end

    def visit_extend(node)
      check_semicolon(node)
    end

    def visit_mixin(node)
      check_semicolon(node)
    end

    def visit_variable(node)
      check_semicolon(node)
    end

  private

    def has_nested_properties?(node)
      node.children.any? { |n| n.is_a?(Sass::Tree::PropNode) }
    end

    def check_semicolon(node)
      if has_space_before_semicolon?(node)
        line = node.source_range.start_pos.line
        add_lint line, 'Declaration should be terminated by a semicolon'
      elsif !ends_with_semicolon?(node)
        line = node.source_range.start_pos.line
        add_lint line,
                 'Declaration should not have a space before ' \
                 'the terminating semicolon'
      end
    end

    # Checks that the node is ended by a semicolon (with no whitespace)
    def ends_with_semicolon?(node)
      source_from_range(node.source_range) =~ /;$/
    end

    def has_space_before_semicolon?(node)
      source_from_range(node.source_range) =~ /\s;$/
    end
  end
end
