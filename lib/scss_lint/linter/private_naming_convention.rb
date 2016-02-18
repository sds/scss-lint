module SCSSLint
  # Verifies that variables, functions, and mixins that follow the private naming convention are
  # defined and used within the same file.
  class Linter::PrivateNamingConvention < Linter
    include LinterRegistry

    def visit_root(node)
      # Register all top-level function, mixin, and variable definitions.
      node.children.each_with_object([]) do |child_node|
        if child_node.is_a?(Sass::Tree::FunctionNode)
          register_node child_node, 'function'
        elsif child_node.is_a?(Sass::Tree::MixinDefNode)
          register_node child_node, 'mixin'
        elsif child_node.is_a?(Sass::Tree::VariableNode)
          register_node child_node, 'variable'
        else
          yield
        end
      end

      # After we have visited everything, we want to see if any private things
      # were defined but not used.
      after_visit_all
    end

    def visit_script_funcall(node)
      check_privacy(node, 'function')
      yield # Continue linting any arguments of this function call
    end

    def visit_mixin(node)
      check_privacy(node, 'mixin')
      yield # Continue into content block of this mixin's block
    end

    def visit_script_variable(node)
      check_privacy(node, 'variable')
    end

  private

    def register_node(node, node_type, node_text = node.name)
      return unless private?(node)

      @private_definitions ||= {}
      @private_definitions[node_type] ||= {}

      @private_definitions[node_type][node_text] = {
        node: node,
        times_used: 0,
      }
    end

    def check_privacy(node, node_type, node_text = node.name)
      return unless private?(node)

      if @private_definitions &&
          @private_definitions[node_type] &&
          @private_definitions[node_type][node_text]
        @private_definitions[node_type][node_text][:times_used] += 1
        return
      end

      add_lint(
        node, "Private #{node_type} #{node_text} must be defined in the same file it is used")
    end

    def private?(node)
      node.name.start_with?(config['prefix'])
    end

    def after_visit_all
      return unless @private_definitions

      @private_definitions.each do |node_type, nodes|
        nodes.each do |node_text, node_info|
          next if node_info[:times_used] > 0
          add_lint(
            node_info[:node],
            "Private #{node_type} #{node_text} must be used in the same file it is defined"
          )
        end
      end
    end
  end
end
