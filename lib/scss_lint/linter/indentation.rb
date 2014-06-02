module SCSSLint
  # Checks for consistent indentation of nested declarations and rule sets.
  class Linter::Indentation < Linter
    include LinterRegistry

    def visit_root(_node)
      @indent_width = config['width']
      @indent = 0
      yield
    end

    def check_and_visit_children(node)
      # Don't continue checking children as the moment a parent's indentation is
      # off it's likely the children will be as will. We don't display the child
      # indentation problems as that would likely make the lint too noisy.
      return if check_indentation(node)

      @indent += @indent_width
      yield
      @indent -= @indent_width
    end

    def check_indentation(node)
      return unless node.line

      # Ignore the case where the node is on the same line as its previous
      # sibling or its parent, as indentation isn't possible
      return if (previous = previous_node(node)) &&
        (previous.line == node.line ||
         previous.source_range.end_pos.line == node.line)

      actual_indent = engine.lines[node.line - 1][/^(\s*)/, 1]

      return if actual_indent.length == @indent

      add_lint(node.line,
               "Line should be indented #{@indent} spaces, " \
               "but was indented #{actual_indent.length} spaces")
      true
    end

    # Deal with `else` statements
    def visit_if(node, &block)
      check_and_visit_children(node, &block)
      visit(node.else) if node.else
    end

    # Need to define this explicitly since @at-root directives can contain
    # inline selectors which produces the same parse tree as if the selector was
    # nested within it. For example:
    #
    #   @at-root {
    #     .something {
    #       ...
    #     }
    #   }
    #
    # ...and...
    #
    #   @at-root .something {
    #     ...
    #   }
    #
    # ...produce the same parse tree, but result in different indentation
    # levels.
    def visit_atroot(node, &block)
      if at_root_contains_inline_selector?(node)
        return if check_indentation(node)
        yield
      else
        check_and_visit_children(node, &block)
      end
    end

    # Define node types that increase indentation level
    alias_method :visit_directive, :check_and_visit_children
    alias_method :visit_each,      :check_and_visit_children
    alias_method :visit_for,       :check_and_visit_children
    alias_method :visit_function,  :check_and_visit_children
    alias_method :visit_media,     :check_and_visit_children
    alias_method :visit_mixin,     :check_and_visit_children
    alias_method :visit_mixindef,  :check_and_visit_children
    alias_method :visit_prop,      :check_and_visit_children
    alias_method :visit_rule,      :check_and_visit_children
    alias_method :visit_supports,  :check_and_visit_children
    alias_method :visit_while,     :check_and_visit_children

    # Define node types to check indentation of (notice comments are left out)
    alias_method :visit_charset,   :check_indentation
    alias_method :visit_content,   :check_indentation
    alias_method :visit_cssimport, :check_indentation
    alias_method :visit_extend,    :check_indentation
    alias_method :visit_import,    :check_indentation
    alias_method :visit_return,    :check_indentation
    alias_method :visit_variable,  :check_indentation
    alias_method :visit_warn,      :check_indentation

  private

    def at_root_contains_inline_selector?(node)
      return unless node.children.any?

      same_position?(node.source_range.end_pos, node.children.first.source_range.start_pos)
    end
  end
end
