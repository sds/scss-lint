module SCSSLint
  class Linter::ColorKeyword < Linter
    include LinterRegistry

    def visit_script_color(node)
      add_color_lint(node, node.original) if color_keyword?(node.original)
    end

    def visit_script_string(node)
      return unless node.type == :identifier

      remove_quoted_strings(node.value).scan(/[a-z]+/i) do |word|
        add_color_lint(node, word) if color_keyword?(word)
      end
    end

  private

    def add_color_lint(node, original)
      hex_form = Sass::Script::Color.new(color_rgb(original)).inspect
      add_lint(node,
               "Color `#{original}` should be written in hexadecimal form " <<
               "as `#{shortest_hex_form(hex_form)}`")
    end

    def color_keyword?(string)
      !!color_rgb(string)
    end

    def color_rgb(string)
      Sass::Script::Color::COLOR_NAMES[string]
    end
  end
end
