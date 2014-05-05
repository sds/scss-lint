module SCSSLint
  # Checks for misspelled properties.
  class Linter::PropertySpelling < Linter
    include LinterRegistry

    def visit_root(_node)
      @extra_properties = config['extra_properties'].to_set
      yield # Continue linting children
    end

    def visit_prop(node)
      # Ignore properties with interpolation
      return if node.name.count > 1 || !node.name.first.is_a?(String)

      name = node.name.join

      # Ignore vendor-prefixed properties
      return if name.start_with?('-')
      return if KNOWN_PROPERTIES.include?(name) ||
        @extra_properties.include?(name)

      add_lint(node, "Unknown property #{name}")
    end

  private

    KNOWN_PROPERTIES = File.open(File.join(SCSS_LINT_DATA, 'properties.txt'))
                           .read
                           .split
                           .to_set
  end
end
