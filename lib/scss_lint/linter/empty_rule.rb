module SCSSLint
  class Linter::EmptyRule < Linter
    include LinterRegistry

    def visit_rule(node)
      add_lint(node) if node.children.empty?
      yield # Continue linting children
    end

    def description
      'Empty rule'
    end
  end
end
