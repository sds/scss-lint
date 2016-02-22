module SCSSLint
  # Verifies that variables, functions, and mixins that follow the private
  # naming convention are defined and used within the same file.
  class Linter::PrivateNamingConvention < Linter # rubocop:disable ClassLength
    include LinterRegistry

    DEFINING_CLASSES = [
      Sass::Tree::FunctionNode,
      Sass::Tree::MixinDefNode,
      Sass::Tree::VariableNode,
    ].freeze

    def visit_root(node)
      # Register all top-level function, mixin, and variable definitions.
      node.children.each_with_object([]) do |child_node|
        if DEFINING_CLASSES.include?(child_node.class)
          register_node child_node
        else
          yield
        end
      end

      # After we have visited everything, we want to see if any private things
      # were defined but not used.
      after_visit_all
    end

    def visit_script_funcall(node)
      check_privacy(node, Sass::Tree::FunctionNode)
      yield # Continue linting any arguments of this function call
    end

    def visit_mixin(node)
      check_privacy(node, Sass::Tree::MixinDefNode)
      yield # Continue into content block of this mixin's block
    end

    def visit_script_variable(node)
      check_privacy(node, Sass::Tree::VariableNode)
    end

  private

    def register_node(node, node_text = node.name)
      return unless private?(node)

      @private_definitions ||= {}
      @private_definitions[node.class.name] ||= {}

      @private_definitions[node.class.name][node_text] = {
        node: node,
        times_used: 0,
      }
    end

    def check_privacy(node, defining_node_class, node_text = node.name)
      return unless private?(node)

      # Look at top-level private definitions
      if @private_definitions &&
          @private_definitions[defining_node_class.name] &&
          @private_definitions[defining_node_class.name][node_text]
        @private_definitions[defining_node_class.name][node_text][:times_used] += 1
        return
      end

      # We did not find a top-level private definition, so let's traverse up the
      # tree, looking for private definitions of this node that are scoped.
      looking_for = {
        node: node,
        defining_class: defining_class_for(node),
        location: location_from_range(node.source_range),
      }
      return if node_defined_earlier_in_branch?(node.node_parent, looking_for)

      node_type = humanize_node_class(node)
      add_lint(
        node,
        "Private #{node_type} #{node_text} must be defined in the same file it is used"
      )
    end

    def node_defined_earlier_in_branch?(node_to_look_in, looking_for)
      # Look at all of the children of this node and return true if we find a
      # defining node that matches in name and type.
      node_to_look_in.children.each_with_object([]) do |child_node|
        break unless before?(child_node, looking_for[:location])
        next unless child_node.class == looking_for[:defining_class]
        next unless child_node.name == looking_for[:node].name

        return true # We found a match, so we are done
      end

      # We are at the top of the branch and don't want to check the root branch,
      # since that is handled elsewhere, which means that we did not find a
      # match.
      return false unless node_to_look_in.node_parent.node_parent

      # We did not find a match yet, and haven't reached the top of the branch,
      # so recurse.
      if node_to_look_in.node_parent
        node_defined_earlier_in_branch?(node_to_look_in.node_parent, looking_for)
      end
    end

    def private?(node)
      node.name.start_with?(config['prefix'])
    end

    def before?(node, before_location)
      location = location_from_range(node.source_range)
      return true if location.line < before_location.line
      if location.line == before_location.line &&
          location.column < before_location.column
        return true
      end
      false
    end

    def after_visit_all
      return unless @private_definitions

      @private_definitions.each do |node_type, nodes|
        nodes.each do |node_text, node_info|
          next if node_info[:times_used] > 0
          node_type = humanize_node_class(node_info[:node])
          add_lint(
            node_info[:node],
            "Private #{node_type} #{node_text} must be used in the same file it is defined"
          )
        end
      end
    end

    def humanize_node_class(node)
      case node
      when Sass::Tree::FunctionNode
        'function'
      when Sass::Tree::MixinDefNode
        'mixin'
      when Sass::Tree::VariableNode
        'variable'
      end
    end

    def defining_class_for(node)
      case node
      when Sass::Script::Tree::Funcall
        Sass::Tree::FunctionNode
      when Sass::Tree::MixinNode
        Sass::Tree::MixinDefNode
      when Sass::Script::Tree::Variable
        Sass::Tree::VariableNode
      end
    end
  end
end
