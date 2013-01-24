require 'sass'

module SCSSLint
  class Linter::ShorthandLinter < Linter
    include LinterRegistry

    class << self
      def run(engine)
        lints = []
        engine.tree.each do |node|
          if node.is_a?(Sass::Tree::PropNode)
            lints << check_valid_shorthand_value(node)
          end
        end
        lints.compact
      end

      def description
        'Property values should use the shortest shorthand syntax allowed'
      end

    private

      def check_valid_shorthand_value(prop_node)
        if prop_node.value.is_a?(Sass::Script::String) &&
           prop_node.value.to_s.strip =~ /\A(\S+\s+\S+(\s+\S+){0,2})\Z/
          return create_lint(prop_node) unless valid_shorthand?($1)
        end
      end

      def valid_shorthand?(shorthand)
        values = shorthand.split(/\s+/)

        if values[0] == values[1] &&
           values[1] == values[2] &&
           values[2] == values[3]
          false
        elsif values[0] == values[1] && values[2].nil? && values[3].nil?
          false
        elsif values[0] == values[2] && values[1] == values[3]
          false
        elsif values[0] == values[2] && values[3].nil?
          false
        elsif values[1] == values[3]
          false
        else
          true
        end
      end
    end
  end
end
