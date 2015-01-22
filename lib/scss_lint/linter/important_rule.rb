module SCSSLint
  class Linter::ImportantRule < Linter
    include LinterRegistry

    def visit_prop(node)
      return unless node.to_sass.include?('!important')

      add_lint(node, '!important should not be used')
    end
  end
end