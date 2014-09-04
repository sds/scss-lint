module SCSSLint
  # Checks the order of nested items within a rule set.
  class Linter::DeclarationOrder < Linter
    include LinterRegistry

    DECLARATION_ORDER = [
      Sass::Tree::ExtendNode,
      Sass::Tree::PropNode,
      Sass::Tree::RuleNode,
    ]

    def visit_rule(node)
      children = node.children.select { |n| important_node?(n) }
                              .map(&:class)

      sorted_children = children.sort do |a, b|
        DECLARATION_ORDER.index(a) <=> DECLARATION_ORDER.index(b)
      end

      if children != sorted_children
        add_lint(node.children.first, MESSAGE)
      end

      yield # Continue linting children
    end

  private

    MESSAGE =
      'Rule sets should start with @extend declarations, followed by ' \
      'properties and nested rule sets, in that order'

    def important_node?(node)
      DECLARATION_ORDER.include? node.class
    end
  end
end
