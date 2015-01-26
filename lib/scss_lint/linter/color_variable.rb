module SCSSLint
  # Ensures color literals are used only in variable declarations.
  class Linter::ColorVariable < Linter
    include LinterRegistry

    COLOR_REGEX = /#?[a-f0-9]{3,6}/i

    def visit_script_color(node)
      return if in_variable_declaration?(node)

      record_lint(node)
    end

    def visit_script_string(node)
      remove_quoted_strings(node.value).scan(/(^|\s)(#?[a-z0-9]+)(?=\s|$)/i) do |_, word|
        next unless color?(word)

        record_lint(node)
      end
    end

  private

    def record_lint(node)
      add_lint node, 'Color literals should only be used in variable ' \
                     'declarations; they should be referred to via variable ' \
                     'everywhere else.'
    end

    def in_variable_declaration?(node)
      parent = node.node_parent
      parent.is_a?(Sass::Script::Tree::Literal) &&
        parent.node_parent.is_a?(Sass::Tree::VariableNode)
    end

    def color?(string)
      color_keyword?(string) || color_hex?(string)
    end

    def color_hex?(string)
      string =~ COLOR_REGEX
    end

    def color_keyword?(string)
      color_rgb(string) && string != 'transparent'
    end

    def color_rgb(string)
      Sass::Script::Value::Color::COLOR_NAMES[string]
    end
  end
end
