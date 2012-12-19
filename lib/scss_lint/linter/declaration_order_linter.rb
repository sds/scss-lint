require 'sass'

module SCSSLint
  class Linter::DeclarationOrderLinter < Linter
    include LinterRegistry

    DECLARATION_ORDER = [
      Sass::Tree::ExtendNode,
      Sass::Tree::PropNode,
      Sass::Tree::RuleNode,
    ]

    class << self
      def run(engine)
        lints = []
        engine.tree.each do |node|
          if node.is_a?(Sass::Tree::RuleNode)
            lints << check_order_of_declarations(node)
          end
        end
        lints.compact
      end

      def description
        'Rule sets should start with @extend declarations, followed by ' <<
        'properties and nested rule sets, in that order'
      end

    private

      def important_node?(node)
        case node
        when *DECLARATION_ORDER
          true
        end
      end

      def check_order_of_declarations(rule_node)
        children = rule_node.children.select { |node| important_node?(node) }.
                                      map { |node| node.class }

        # Inefficient, but we're not sorting thousands of declarations
        sorted_children = children.sort do |x,y|
          DECLARATION_ORDER.index(x) <=> DECLARATION_ORDER.index(y)
        end

        if children != sorted_children
          return create_lint(rule_node.children.first)
        end
      end
    end
  end
end
