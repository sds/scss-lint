module SCSSLint
  class Linter::PlaceholderInExtend < Linter
    include LinterRegistry

    def visit_extend(node)
      # The array returned by the parser is a bit awkward in that it splits on
      # every word boundary (so %placeholder becomes ['%', 'placeholder']).
      selector = node.selector.join

      add_lint(node) unless selector.start_with?('%')
    end

    def description
      'Always use placeholder selectors (e.g. %some-placeholder) with @extend'
    end
  end
end
