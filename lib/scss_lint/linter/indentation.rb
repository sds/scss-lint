module SCSSLint
  # Checks for consistent indentation of nested declarations and rule sets.
  class Linter::Indentation < Linter
    include LinterRegistry

    def visit_root(node)
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
      return if (previous = previous_node(node)) && previous.line == node.line

      actual_indent = engine.lines[node.line - 1][/^(\s*)/, 1]

      if actual_indent.length != @indent
        add_lint(node.line,
                 "Line should be indented #{@indent} spaces, " <<
                 "but was indented #{actual_indent.length} spaces")
        return true
      end
    end

    # Deal with `else` statements
    def visit_if(node, &block)
      check_and_visit_children(node, &block)
      visit(node.else) if node.else
    end

    # Define node types that increase indentation level
    alias :visit_directive  :check_and_visit_children
    alias :visit_each       :check_and_visit_children
    alias :visit_for        :check_and_visit_children
    alias :visit_function   :check_and_visit_children
    alias :visit_media      :check_and_visit_children
    alias :visit_mixin      :check_and_visit_children
    alias :visit_mixindef   :check_and_visit_children
    alias :visit_prop       :check_and_visit_children
    alias :visit_rule       :check_and_visit_children
    alias :visit_supports   :check_and_visit_children
    alias :visit_while      :check_and_visit_children

    # Define node types to check indentation of (notice comments are left out)
    alias :visit_charset    :check_indentation
    alias :visit_content    :check_indentation
    alias :visit_cssimport  :check_indentation
    alias :visit_extend     :check_indentation
    alias :visit_import     :check_indentation
    alias :visit_return     :check_indentation
    alias :visit_variable   :check_indentation
    alias :visit_warn       :check_indentation
  end
end
