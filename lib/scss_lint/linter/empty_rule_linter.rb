require 'sass'

module SCSSLint
  class Linter::EmptyRuleLinter < Linter
    include LinterRegistry

    class << self
      def run(engine)
        lints = []
        engine.tree.each do |node|
          if node.is_a?(Sass::Tree::RuleNode)
            lints << check_empty_rule(node)
          end
        end
        lints.compact
      end

      def description
        'Empty rule'
      end

    private

      def check_empty_rule(rule_node)
        create_lint(rule_node) if rule_node.children.empty?
      end
    end
  end
end
