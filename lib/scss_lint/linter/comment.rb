module SCSSLint
  # Checks for uses of renderable comments (/* ... */)
  class Linter::Comment < Linter
    include LinterRegistry

    def visit_comment(node)
      add_lint(node, 'Use `//` comments everywhere') unless node.invisible?
    end
  end
end
