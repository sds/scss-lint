module SCSSLint
  # Adds control comment functionality
  module ControlComments
    attr_reader :disable_stack, :disabled_lines

  private

    def initialize_vars
      @disable_stack = [] if @disable_stack.nil?
      @disabled_lines = Set.new if @disabled_lines.nil?
    end

    def filter_lints
      initialize_vars

      @lints = lints.select { |lint| !disabled_lines.include?(lint.location.line) }
    end

    def enter_visit_control_comment(node)  # rubocop:disable CyclomaticComplexity
      return unless node.is_a?(Sass::Tree::CommentNode)

      initialize_vars

      match = %r{/* scss\-lint:(disable|enable) (.*?) \*/}.match(node.value[0])
      return if match.nil?

      linters = match[2].split(/\s*,\s*|\s+/)
      return unless match[2] == 'all' || linters.include?(name)

      case match[1]
      when 'disable' then @disable_stack << node
      when 'enable' then pop_control_comment_stack(node)
      end
    end

    def exit_visit_control_comment(node)
      initialize_vars

      while @disable_stack.last && @disable_stack.last.node_parent == node
        pop_control_comment_stack(node)
      end
    end

    def pop_control_comment_stack(node)
      comment_node = @disable_stack.pop

      return unless comment_node

      start_line = comment_node.line

      # Find the deepest child that has a line number to which a lint might apply (if it is a
      # control comment enabe node, it will be the line of the comment itself)
      child = node
      loop do
        break unless child.children.last.is_a?(Sass::Tree::Node)
        child = child.children.last
      end

      end_line = child.line

      disabled_lines.merge((start_line..end_line))
    end
  end
end
