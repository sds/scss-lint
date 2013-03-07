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
      SHORTHANDABLE_PROPERTIES = %w[border-color
                                    border-radius
                                    border-style
                                    border-width
                                    margin
                                    padding]

      def check_valid_shorthand_value(prop_node)
        unless SHORTHANDABLE_PROPERTIES.include? prop_node.name.first.to_s
          return
        end

        if prop_node.value.to_s.strip =~ /\A(\S+\s+\S+(\s+\S+){0,2})\Z/
          return create_lint(prop_node) unless valid_shorthand?($1)
        end
      end

      def valid_shorthand?(shorthand)
        values = shorthand.split(/\s+/)
        top, right, bottom, left = values

        if top == right && right == bottom && bottom == left
          false
        elsif top == right && bottom.nil? && left.nil?
          false
        elsif top == bottom && right == left
          false
        elsif top == bottom && left.nil?
          false
        elsif right == left
          false
        else
          true
        end
      end
    end
  end
end
