require 'sass'

module SCSSLint
  class Linter::SingleLinePerSelector < Linter
    include LinterRegistry

    def visit_rule(node)
      add_lint(node) unless node.rule.grep(/,[^\n]/).empty?
      yield # Continue linting children
    end

    def description
      'Each selector should be on its own line'
    end
  end
end
