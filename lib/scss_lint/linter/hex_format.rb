module SCSSLint
  # Checks for hexadecimal colors that can be shortened.
  class Linter::HexFormat < Linter
    include LinterRegistry

    def visit_script_color(node)
      return unless color = source_from_range(node.source_range)[HEX_REGEX, 1]

      unless valid_hex_format?(color)
        add_hex_lint(node, color)
      end
    end

    def visit_script_string(node)
      return unless node.type == :identifier

      node.value.scan(HEX_REGEX) do |match|
        add_hex_lint(node, match.first) unless valid_hex_format?(match.first)
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
