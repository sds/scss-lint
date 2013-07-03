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

    def visit_rule(node)
      add_lint(node) if selector_contains_bad_placeholder?(node.rule)
      yield # Continue linting into content block of this rule definition
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
      'Names of variables, functions, mixins, and placeholders should be ' <<
      'lowercase and use hyphens instead of underscores.'
    end

  private

    INVALID_CHARS = '[_A-Z]'

    def selector_contains_bad_placeholder?(selector)
      selector.reject { |item| item.is_a? Sass::Script::Node }.
               join.
               split(/\s+/).
               any? { |selector_str| selector_str =~ /%\w*#{INVALID_CHARS}/ }
    end

    def check(node)
      add_lint(node) if node.name =~ /#{INVALID_CHARS}/
    end
  end
end
