
module SCSSLint
  class Linter::CapitalizationInSelectorLinter < Linter
    include LinterRegistry

    def visit_rule(node)
      if node.rule.first =~ /[A-Z]/
        add_lint(node)
      end

      yield # Continue linting children
    end

    def description
      'Selectors should be lowercase'
    end
  end
end
