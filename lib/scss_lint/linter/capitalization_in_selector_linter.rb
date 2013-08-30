module SCSSLint
  class Linter::CapitalizationInSelectorLinter < Linter
    include LinterRegistry

    def visit_rule(node)
      add_lint(node) if node.rule.first =~ /[A-Z]/

      yield # Continue linting children
    end

    def description
      'Selectors should be lowercase'
    end
  end
end
