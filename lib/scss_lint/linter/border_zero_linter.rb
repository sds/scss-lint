require 'sass'

module SCSSLint
  class Linter::BorderZeroLinter < Linter
    include LinterRegistry

    def visit_prop(node)
      return unless node.name.first.to_s == 'border'
      add_lint(node) if node.value.to_sass.strip == 'none'
    end

    def description
      '`border: 0;` is preferred over `border: none;`'
    end
  end
end
