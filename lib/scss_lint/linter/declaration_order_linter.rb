require 'sass'

module SCSSLint
  class Linter::DeclarationOrderLinter < Linter
    include LinterRegistry

    DECLARATION_ORDER = [
      Sass::Tree::ExtendNode,
      Sass::Tree::PropNode,
      Sass::Tree::RuleNode,
    ]

    def visit_rule(node)
      children = node.children.select { |node| important_node?(node) }.
                               map { |node| node.class }

      sorted_children = children.sort do |a, b|
        DECLARATION_ORDER.index(a) <=> DECLARATION_ORDER.index(b)
      end

      if children != sorted_children
        add_lint(node.children.first)
      end

      yield # Continue linting children
    end

    def description
      'Rule sets should start with @extend declarations, followed by ' <<
      'properties and nested rule sets, in that order'
    end

  private

    def important_node?(node)
      DECLARATION_ORDER.include? node.class
    end
  end
end
