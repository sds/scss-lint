module SCSSLint
  # Reports the lack of empty lines between block defintions.
  class Linter::EmptyLineBetweenBlocks < Linter
    include LinterRegistry

    def visit_function(node)
      check(node, '@function')
      yield
    end

    def visit_mixin(node)
      # Ignore @includes which don't have any block content
      check(node, '@include') if node.children
                                     .any? { |child| child.is_a?(Sass::Tree::Node) }
      yield
    end

    def visit_mixindef(node)
      check(node, '@mixin')
      yield
    end

    def visit_rule(node)
      check(node, 'Rule')
      yield
    end

  private

    MESSAGE_FORMAT = '%s declaration should be %s by an empty line'

    def check(node, type)
      return if config['ignore_single_line_blocks'] && node_on_single_line?(node)
      check_preceding_node(node, type)
      check_following_node(node, type)
    end

    def check_following_node(node, type)
      if (following_node = next_node(node)) && (next_start_line = following_node.line)
        unless engine.lines[next_start_line - 2].strip.empty?
          add_lint(next_start_line - 1, MESSAGE_FORMAT % [type, 'followed'])
        end
      end
    end

    # In cases where the previous node is not a block declaration, we won't
    # have run any checks against it, so we need to check here if the previous
    # line is an empty line
    def check_preceding_node(node, type)
      case prev_node(node)
      when
        nil,
        Sass::Tree::FunctionNode,
        Sass::Tree::MixinNode,
        Sass::Tree::MixinDefNode,
        Sass::Tree::RuleNode,
        Sass::Tree::CommentNode
        # Ignore
      else
        unless engine.lines[node.line - 2].strip.empty?
          add_lint(node.line, MESSAGE_FORMAT % [type, 'preceded'])
        end
      end
    end

    def next_node(node)
      return unless siblings = node_siblings(node)
      siblings[siblings.index(node) + 1] if siblings.count > 1
    end

    def prev_node(node)
      return unless siblings = node_siblings(node)
      index = siblings.index(node)
      siblings[index - 1] if index > 0 && siblings.count > 1
    end

    def node_siblings(node)
      return unless node && node.node_parent
      node.node_parent
          .children
          .select { |child| child.is_a?(Sass::Tree::Node) }
    end
  end
end
