module SCSSLint
  # Checks for identical root selectors.
  class Linter::DuplicateRoot < Linter
    include LinterRegistry

    def visit_root(node)
      # Root rules are evaluated per document, so use new hashes for eash file
      @roots = {}
      yield # Continue linting children
    end

    def visit_rule(node)
      if @roots[node.rule]
        add_lint node.line,
                 "Merge root rule `#{node.rule.join}` with identical " \
                 "rule on line #{@roots[node.rule].line}"
      else
        @roots[node.rule] = node
      end

      # Don't yield so we only check one level deep
    end

    # Define stubs so we don't check rules nested in other constructs
    %w[
      directive
      media
      mixin
      mixindef
    ].each do |node_type|
      define_method("visit_#{node_type}") { |*args| }
    end
  end
end
