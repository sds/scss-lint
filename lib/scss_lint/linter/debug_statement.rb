module SCSSLint
  class Linter::DebugStatement < Linter
    include LinterRegistry

    def visit_debug(node)
      add_lint(node)
    end

    def description
      '@debug line'
    end
  end
end
