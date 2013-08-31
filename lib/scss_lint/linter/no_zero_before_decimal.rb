module SCSSLint
  class Linter::NoZeroBeforeDecimal < Linter
    include LinterRegistry

    def visit_prop(node)
      # Misleading, but anything that isn't Sass Script is considered an
      # `identifier` in the context of a Sass::Script::String.
      return unless node.value.is_a?(Sass::Script::String) && node.value.type == :identifier

      # Remove string chunks (e.g. `"hello" 3 'world'` -> `3`
      non_string_values = node.value.value.gsub(/"[^"]*"|'[^']'/, '').split

      non_string_values.each do |value|
        add_lint(node) if value =~ /\b0\.\d+/
      end
    end

    def description
      'Leading zero should be omitted in fractional values'
    end
  end
end
