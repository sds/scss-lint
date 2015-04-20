module SCSSLint
  # Checks for uses of renderable comments (/* ... */)
  class Linter::Comment < Linter
    include LinterRegistry

    def visit_comment(node)
      add_lint(node, 'Use `//` comments everywhere') unless node.invisible? || allowed?(node)
    end

  private

    # @param node [CommentNode]
    # @return [Boolean]
    def allowed?(node)
      return false unless config['allowed']
      re = Regexp.new(config['allowed'])

      node.value.join.match(re)
    end
  end
end
