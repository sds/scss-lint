module SCSSLint
  # Checks for uses of a color keyword instead of the preferred hexadecimal
  # form.
  class Linter::ColorKeyword < Linter
    include LinterRegistry

    def visit_script_color(node)
      color = source_from_range(node.source_range)[COLOR_REGEX, 1]

      add_color_lint(node, color) if color_keyword?(color)
    end

    def visit_script_string(node)
      return unless node.type == :identifier

      remove_quoted_strings(node.value).scan(/(^|\s)([a-z]+)(?=\s|$)/i) do |_, word|
        add_color_lint(node, word) if color_keyword?(word)
      end
    end

  private

    COLOR_REGEX = /(#?[a-f0-9]{3,6}|[a-z]+)/i

    def add_color_lint(node, original)
      hex_form = Sass::Script::Value::Color.new(color_rgb(original)).tap do |color|
        color.options = {} # `inspect` requires options to be set
      end.inspect

      add_lint(node,
               "Color `#{original}` should be written in hexadecimal form " <<
               "as `#{shortest_hex_form(hex_form)}`")
    end

    def color_keyword?(string)
      !!color_rgb(string) && string != 'transparent'
    end

    def color_rgb(string)
      Sass::Script::Value::Color::COLOR_NAMES[string]
    end
  end
end
