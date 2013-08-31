module SCSSLint
  class Linter::DeclaredName < Linter
    include LinterRegistry

    def visit_function(node)
      check(node)
      yield # Continue into content block of this function definition
    end

    def visit_mixindef(node)
      check(node)
      yield # Continue into content block of this mixin definition
    end

    def visit_rule(node)
      add_lint(node) if selector_has_bad_placeholder?(node.rule)
      yield # Continue linting into content block of this rule definition
    end

    def visit_variable(node)
      check(node)
      yield # Continue into expression tree for this variable definition
    end

    def description
      'Names of variables, functions, mixins, and placeholders should be ' <<
      'lowercase and use hyphens instead of underscores.'
    end

  private

    def check(node)
      add_lint(node) if node_has_bad_name?(node)
    end
  end
end
