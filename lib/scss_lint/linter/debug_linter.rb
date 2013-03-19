require 'sass'

module SCSSLint
  class Linter::DebugLinter < Linter
    include LinterRegistry

    def visit_debug(node)
      add_lint(node)
    end

    def description
      '@debug line'
    end
  end
end
