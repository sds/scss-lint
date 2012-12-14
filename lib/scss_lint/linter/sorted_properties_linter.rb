require 'sass'

module SCSSLint
  class Linter::SortedPropertiesLinter < Linter
    include LinterRegistry

    class << self
      def run(engine)
        lints = []
        engine.tree.each do |node|
          if node.is_a?(Sass::Tree::RuleNode)
            lints << check_properties_sorted(node)
          end
        end
        lints.compact
      end

      def description
        'Properties should be sorted in alphabetical order'
      end

    private

      def check_properties_sorted(rule_node)
        properties = rule_node.children.select do |node|
          node.is_a?(Sass::Tree::PropNode)
        end

        prop_names = properties.map do |prop_node|
          prop_node.name.first.to_s
        end

        if prop_names.sort != prop_names
          create_lint(properties.first)
        end
      end
    end
  end
end
