require 'sass'

module SCSSLint
  class Linter::DeclaredNameLinter < Linter
    include LinterRegistry

    def visit_function(node)
      check(node)
      yield # Continue into content block of this function definition
    end

    def visit_mixin(node)
      check(node)
      yield # Continue into content block of this mixin's block
    end

    def visit_mixindef(node)
      check(node)
      yield # Continue into content block of this mixin definition
    end

    def visit_variable(node)
      check(node)
      yield # Continue into expression tree for this variable definition
    end

    def visit_script_funcall(node)
      check(node)
    end

    def visit_script_variable(node)
      check(node)
    end

    def description
      'Names of variables, functions, and mixins should be lowercase and not contain underscores. Use hyphens instead.'
    end

  private

    def check(node)
      add_lint(node) if node.name =~ /[_A-Z]/
    end
  end
end
