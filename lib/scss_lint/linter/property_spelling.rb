module SCSSLint
  # Checks for misspelled properties.
  class Linter::PropertySpelling < Linter
    include LinterRegistry

    def visit_prop(node)
      # Ignore properties with interpolation
      return if node.name.count > 1 || !node.name.first.is_a?(String)

      name = node.name.join

      # Ignore vendor-prefixed properties
      return if name.start_with?('-')

      unless KNOWN_PROPERTIES.include?(name)
        add_lint(node, "Unknown property #{name}")
      end
    end

  private

    KNOWN_PROPERTIES = File.open(File.join(SCSS_LINT_DATA, 'properties.txt'))
                           .read
                           .split
                           .to_set
  end
end
