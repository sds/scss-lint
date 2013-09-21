module SCSSLint
  class Linter::HexFormat < Linter
    include LinterRegistry

    def visit_prop(node)
      if node.value.is_a?(Sass::Script::String) &&
         node.value.type == :identifier

        node.value.value.scan(HEX_REGEX) do |match|
          add_hex_lint(node, match.first) unless valid_hex_format?(match.first)
        end
      end

      yield # Continue visiting children
    end

    def visit_script_color(node)
      return unless node.original && node.original.match(HEX_REGEX)

      unless valid_hex_format?(node.original[HEX_REGEX, 1])
        add_hex_lint(node, node.original)
      end
    end

  private

    HEX_REGEX = /(#\h{3,6})/

    def add_hex_lint(node, hex)
      add_lint(node, "Color `#{hex}` should be written as `#{shortest_hex_form(hex)}`")
    end

    def valid_hex_format?(hex)
      hex == shortest_hex_form(hex)
    end
  end
end
