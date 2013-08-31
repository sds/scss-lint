module SCSSLint
  class Linter::UsageName < Linter
    include LinterRegistry

    def visit_extend(node)
      add_lint(node) if selector_has_bad_placeholder?(node.selector)
    end

    def visit_mixin(node)
      check(node)
      yield # Continue into content block of this mixin's block
    end

    def visit_script_funcall(node)
      check(node) unless FUNCTION_WHITELIST.include?(node.name)
    end

    def visit_script_variable(node)
      check(node)
    end

    def description
      'Usages of variables, functions, mixins, and placeholders should be ' <<
      'lowercase and use hyphens instead of underscores.'
    end

  private

    FUNCTION_WHITELIST = %w[
      rotateX rotateY rotateZ
      scaleX scaleY scaleZ
      skewX skewY
      translateX translateY translateZ
    ].to_set

    def check(node)
      add_lint(node) if node_has_bad_name?(node)
    end
  end
end
