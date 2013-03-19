require 'sass'

module SCSSLint
  class Linter::SortedPropertiesLinter < Linter
    include LinterRegistry

    def visit_rule(node)
      properties = node.children.select do |child|
        child.is_a?(Sass::Tree::PropNode)
      end

      prop_names = properties.map do |prop_node|
        prop_node.name.first.to_s
      end

      if prop_names.sort != prop_names
        add_lint(properties.first)
      end

      yield # Continue linting children
    end

    def description
      'Properties should be sorted in alphabetical order'
    end
  end
end
