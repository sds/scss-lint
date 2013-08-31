module SCSSLint
  class Linter::ZeroUnit < Linter
    include LinterRegistry

    def visit_prop(node)
      line = engine.lines[node.line - 1] if node.line
      add_lint(node) if line =~ /^\s*[\w-]+:\s*0[a-z]+;$/i
    end

    def description
      'Properties with a value of zero should be unit-less, e.g. "0" instead of "0px"'
    end
  end
end
