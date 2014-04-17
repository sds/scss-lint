module SCSSLint
  # Checks identical root selectors.
  class Linter::DuplicateRoot < Linter
    include LinterRegistry

    def visit_root(node)
      # Root rules are evaluated per document, so use new hashes for eash file
      @roots = Hash.new
      yield # Continue linting children
    end

    def visit_rule(node)
      # Check to see if we've seen this rule before
      if @roots.has_key?(node.rule)
        add_lint(node.line,
                 "Root #{node.rule} already seen at #{@roots[node.rule]}")
      else
        @roots[node.rule] = node.line
      end
      return # Only check one level deep
    end
  end
end
