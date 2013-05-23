require 'sass'

module SCSSLint
  class Linter::VariableNameLinter < Linter
    include LinterRegistry

    def visit_variable(node)
      add_lint(node) if node.name =~ /[_A-Z]/
    end

    def description
      'Variable names should be lowercase and not contain underscores. Use hyphens to separate words.'
    end
  end
end
