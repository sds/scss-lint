require 'sass'

module SCSSLint
  class Linter::HexLinter < Linter
    include LinterRegistry

    def visit_prop(node)
      if node.value.is_a?(Sass::Script::String) &&
         node.value.to_s =~ /#(\h{3,6})/
        add_lint(node) unless valid_hex?($1)
      end
    end

    def description
      'Hexadecimal color codes should be lowercase and in 3-digit form where possible'
    end

  private

    def valid_hex?(hex)
      [3,6].include?(hex.length) &&
        hex.downcase == hex &&
        !can_be_condensed(hex)
    end

    def can_be_condensed(hex)
      hex.length == 6 &&
        hex[0] == hex[1] &&
        hex[2] == hex[3] &&
        hex[4] == hex[5]
    end
  end
end
