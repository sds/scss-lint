module SCSSLint
  # Checks properties for a trailing semicolon (unless that property is a
  # namespace which has nested properties).
  class Linter::TrailingSemicolonAfterPropertyValue < Linter
    include LinterRegistry

    def visit_prop(node)
      has_nested_props = has_nested_properties?(node)

      if !has_nested_props && !ends_with_semicolon?(node)
        add_lint node.line, 'Property declaration should end with a semicolon'
      end

      yield if has_nested_props
    end

  private

    def has_nested_properties?(node)
      node.children.any? { |n| n.is_a?(Sass::Tree::PropNode) }
    end

    # Checks that the property is ended by a semicolon (with no whitespace)
    def ends_with_semicolon?(node)
      character_at(node.source_range.end_pos) == ';' &&
        character_at(node.source_range.end_pos, -1) !~ /\s/
    end
  end
end
