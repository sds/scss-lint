require 'sass'

module SCSSLint
  class Linter::SingleLinePerSelector < Linter
    include LinterRegistry

    class << self
      def run(engine)
        lints = []
        engine.tree.each do |node|
          if node.is_a?(Sass::Tree::RuleNode)
            lints << check_selector_format(node)
          end
        end
        lints.compact
      end

      def description
        'Each selector should be on its own line'
      end

    private

      def check_selector_format(rule_node)
        create_lint(rule_node) unless rule_node.rule.grep(/,[^\n]/).empty?
      end
    end
  end
end
