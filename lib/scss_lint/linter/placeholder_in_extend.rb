module SCSSLint
  # Checks that `@extend` is always used with a placeholder selector.
  class Linter::PlaceholderInExtend < Linter
    include LinterRegistry

    def visit_extend(node)
      # The array returned by the parser is a bit awkward in that it splits on
      # every word boundary (so %placeholder becomes ['%', 'placeholder']).
      selector = node.selector.join

      unless selector.start_with?('%')
        add_lint(node,
                 'Prefer using placeholder selectors (e.g. %some-placeholder) with @extend')
      end
    end
  end
end
