require 'sass'

module SCSSLint
  class Linter::TypeInIdSelectorLinter < Linter
    include LinterRegistry

    class << self
      def run(engine)
        lints = []
        engine.tree.each do |node|
          if node.is_a?(Sass::Tree::RuleNode)
            lints << check_type_in_selector(node)
          end
        end
        lints.compact
      end

      def description
        'Avoid ID names with unnecessary type selectors (e.g. prefer `#id` over `p#id`)'
      end

    private

      def check_type_in_selector(rule_node)
        selectors = rule_node.rule.first.to_s.split(',')

        selectors.each do |selector|
          return create_lint(rule_node) if selector.strip =~ /^[a-z0-9]+#.*/i
        end

        nil
      end
    end
  end
end
