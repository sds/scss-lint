module SCSSLint
  # Check for pixel value usage
  class Linter::NoPixels < Linter
    include LinterRegistry

    def visit_prop(node)
      return unless node.value.value.to_s.include? 'px'
      add_lint(node, 'Pixel units should not be used')
    end

  end
end