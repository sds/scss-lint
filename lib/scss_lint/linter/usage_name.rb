module SCSSLint
  # Checks for variable/function/mixin/placeholder uses which contains uppercase
  # characters or underscores.
  class Linter::UsageName < Linter
    include LinterRegistry

    def visit_extend(node)
      if selector_has_bad_placeholder?(node.selector)
        add_name_lint(node, node.selector.join, 'placeholder')
      end
    end

    def visit_mixin(node)
      check(node, 'mixin')
      yield # Continue into content block of this mixin's block
    end

    def visit_script_funcall(node)
      check(node, 'function') unless FUNCTION_WHITELIST.include?(node.name)
    end

    def visit_script_variable(node)
      check(node, 'variable')
    end

  private

    FUNCTION_WHITELIST = %w[
      rotateX rotateY rotateZ
      scaleX scaleY scaleZ
      skewX skewY
      translateX translateY translateZ
    ].to_set

    def check(node, node_type)
      add_name_lint(node, node.name, node_type) if node_has_bad_name?(node)
    end

    def add_name_lint(node, name, node_type)
      fixed_name = name.downcase.gsub(/_/, '-')

      add_lint(node, "All uses of #{node_type} `#{name}` should be written " <<
                     "in lowercase as `#{fixed_name}`")
    end

    # Given a selector array, returns whether it contains any placeholder
    # selectors with invalid names.
    def selector_has_bad_placeholder?(selector_array)
      extract_string_selectors(selector_array).any? do |selector_str|
        selector_str =~ /%\w*#{INVALID_NAME_CHARS}/
      end
    end
  end
end
