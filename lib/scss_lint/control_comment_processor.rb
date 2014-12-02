require 'set'

module SCSSLint
  # Tracks which lines have been disabled for a given linter.
  class ControlCommentProcessor
    def initialize(linter)
      @disable_stack = []
      @disabled_lines = Set.new
      @linter = linter
    end

    # Filter lints given the comments that were processed in the document.
    #
    # @param lints [Array<SCSSLint::Lint>]
    def filter_lints(lints)
      lints.reject { |lint| @disabled_lines.include?(lint.location.line) }
    end

    # Executed before a node has been visited.
    #
    # @param node [Sass::Tree::Node]
    def before_node_visit(node)
      return unless node.is_a?(Sass::Tree::CommentNode)

      return unless match = %r{
        /\*\s* # Comment start marker
        scss-lint:
        (?<command>disable|enable)\s+
        (?<linters>.*?)
        \s*\*/ # Comment end marker
      }x.match(node.value.first)

      linters = match[:linters].split(/\s*,\s*|\s+/)
      return unless linters.include?('all') || linters.include?(@linter.name)

      process_command(match[:command], node)
    end

    # Executed after a node has been visited.
    #
    # @param node [Sass::Tree::Node]
    def after_node_visit(node)
      while @disable_stack.any? && @disable_stack.last.node_parent == node
        pop_control_comment_stack(node)
      end
    end

  private

    def process_command(command, node)
      case command
      when 'disable'
        @disable_stack << node
      when 'enable'
        pop_control_comment_stack(node)
      end
    end

    def pop_control_comment_stack(node)
      return unless comment_node = @disable_stack.pop

      start_line = comment_node.line

      # Find the deepest child that has a line number to which a lint might
      # apply (if it is a control comment enable node, it will be the line of
      # the comment itself).
      child = node
      while child.children.last.is_a?(Sass::Tree::Node)
        child = child.children.last
      end

      end_line = child.line

      @disabled_lines.merge(start_line..end_line)
    end
  end
end
