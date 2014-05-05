module SCSSLint
  # Reports when `border: 0` can be used instead of `border: none`.
  class Linter::BorderZero < Linter
    include LinterRegistry

    def visit_prop(node)
      return unless BORDER_PROPERTIES.include?(node.name.first.to_s)
      return unless node.value.to_sass.strip == 'none'

      add_lint(node, '`border: 0;` is preferred over `border: none;`')
    end

  private

    BORDER_PROPERTIES = %w[
      border
      border-top
      border-right
      border-bottom
      border-left
    ]
  end
end
