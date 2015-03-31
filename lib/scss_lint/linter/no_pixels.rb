module SCSSLint
  # Check for pixel value usage
  class Linter::NoPixels < Linter
    include LinterRegistry

    def visit_prop(node)
      return unless node.value.value.to_s.include? 'px'
      ignored_properties = config['ignored_properties'].to_set
      return if ignored_properties.include? node.name.join
      add_lint(node, 'Pixel units should not be used')
    end

  end
end