module SCSSLint
  class Linter::TypeInIdSelector < Linter
    include LinterRegistry

    def visit_rule(node)
      selectors = node.rule.first.to_s.split(',')
      selectors.each do |selector|
        add_lint(node) if selector.strip =~ /^[a-z0-9]+#.*/i
      end

      yield # Continue linting children
    end

    def description
      'Avoid ID names with unnecessary type selectors (e.g. prefer `#id` over `p#id`)'
    end
  end
end
