module SCSSLint
  class Linter::ColorKeyword < Linter
    include LinterRegistry

    def visit_script_string(node)
      add_lint(node) if color_keyword?(node.value)
    end

    def description
      'Colors should be specified as hexadecimal values, not names'
    end

  private

    def color_keyword?(string)
      !!Sass::Script::Color::COLOR_NAMES[string]
    end
  end
end
