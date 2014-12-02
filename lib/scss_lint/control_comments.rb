require 'set'

module SCSSLint
  # Contains functionality for enabling/disabling linters via comments.
  module ControlComments
  private

    def initialize_vars
      @disable_stack = [] if @disable_stack.nil?
      @disabled_lines = Set.new if @disabled_lines.nil?
    end

    def filter_lints
      initialize_vars

      @lints = lints.reject { |lint| @disabled_lines.include?(lint.location.line) }
    end

    def enter_visit_control_comment(node)
      return unless node.is_a?(Sass::Tree::CommentNode)

      return unless match = %r{
        /\*\s* # Comment start marker
        scss-lint:
        (?<command>disable|enable)\s+
        (?<linters>.*?)
        \s*\*/ # Comment end marker
      }x.match(node.value.first)

      linters = match[:linters].split(/\s*,\s*|\s+/)
      return unless linters.include?('all') || linters.include?(name)

      initialize_vars
      process_command(match[:command], node)
    end

    def process_command(command, node)
      case command
      when 'disable'
        @disable_stack << node
      when 'enable'
        pop_control_comment_stack(node)
      end
    end

    def exit_visit_control_comment(node)
      initialize_vars

      while @disable_stack.any? && @disable_stack.last.node_parent == node
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
