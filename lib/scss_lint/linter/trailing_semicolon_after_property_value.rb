module SCSSLint
  # Checks properties for a trailing semicolon (unless that property is a
  # namespace which has nested properties).
  class Linter::TrailingSemicolonAfterPropertyValue < Linter
    include LinterRegistry

    def visit_prop(node)
      has_nested_props = has_nested_properties?(node)

      unless has_nested_props
        if has_space_before_semicolon?(node)
          line = node.source_range.end_pos
          add_lint line, 'Property declaration should be terminated by a semicolon'
        elsif !ends_with_semicolon?(node)
          # Adjust line since lack of semicolon results in end of source range
          # being on the next line
          line = node.source_range.end_pos.line - 1
          add_lint line,
                   'Property declaration should not have a space before ' <<
                   'the terminating semicolon'
        end
      end

      yield if has_nested_props
    end

  private

    def has_nested_properties?(node)
      node.children.any? { |n| n.is_a?(Sass::Tree::PropNode) }
    end

    # Checks that the property is ended by a semicolon (with no whitespace)
    def ends_with_semicolon?(node)
      source_from_range(node.source_range) =~ /;$/
    end

    def has_space_before_semicolon?(node)
      source_from_range(node.source_range) =~ /\s;$/
    end
  end
end
