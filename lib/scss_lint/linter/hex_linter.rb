require 'sass'

module SCSSLint
  class Linter::HexLinter < Linter
    include LinterRegistry

    class << self
      def run(engine)
        lints = []
        engine.tree.each do |node|
          if node.is_a?(Sass::Tree::PropNode)
            lints << check_valid_hex_value(node)
          end
        end
        lints.compact
      end

      def description
        'Hexadecimal color codes should be lowercase and in 3-digit form where possible'
      end

    private

      def check_valid_hex_value(prop_node)
        if prop_node.value.is_a?(Sass::Script::String) &&
           prop_node.value.to_s =~ /#(\h{3,6})/
          return create_lint(prop_node) unless valid_hex?($1)
        end
      end

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
end
