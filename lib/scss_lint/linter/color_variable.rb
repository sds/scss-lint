module SCSSLint
  # Ensures color literals are used only in variable declarations.
  class Linter::ColorVariable < Linter
    include LinterRegistry

    def visit_script_color(node)
      return if in_variable_declaration?(node) ||
                in_map_declaration?(node) ||
                in_rgba_function_call?(node)

      # Source range sometimes includes closing parenthesis, so extract it
      color = source_from_range(node.source_range)[/(#?[a-z0-9]+)/i, 1]

      record_lint(node, color) if color?(color)
    end

    def visit_script_string(node)
      remove_quoted_strings(node.value)
        .scan(/(^|\s)(#[a-f0-9]+|[a-z]+)(?=\s|$)/i)
        .select { |_, word| color?(word) }
        .each   { |_, color| record_lint(node, color) }
    end

  private

    def record_lint(node, color)
      add_lint node, "Color literals like `#{color}` should only be used in " \
                     'variable declarations; they should be referred to via ' \
                     'variable everywhere else.'
    end

    def in_variable_declaration?(node)
      parent = node.node_parent
      parent.is_a?(Sass::Script::Tree::Literal) &&
        parent.node_parent.is_a?(Sass::Tree::VariableNode)
    end

    def in_rgba_function_call?(node)
      grandparent = node_ancestor(node, 2)

      grandparent.is_a?(Sass::Script::Tree::Funcall) &&
        grandparent.name == 'rgba'
    end

    def in_map_declaration?(node)
      node_ancestor(node, 2).is_a?(Sass::Script::Tree::MapLiteral)
    end
  end
end
