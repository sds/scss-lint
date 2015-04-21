module SCSSLint
  # Reports the use of literals for properties where variables are prefered.
  class Linter::VariableForProperty < Linter
    include LinterRegistry

    IGNORED_VALUES = %w[currentColor inherit transparent]

    def visit_root(_node)
      @properties = Set.new(config['properties'])
      yield if @properties.any?
    end

    def visit_prop(node)
      property_name = node.name.join
      return unless @properties.include?(property_name)
      return if ignored_value?(node.value)
      return if node.children.first.is_a?(Sass::Script::Tree::Variable)

      add_lint(node, "Property #{property_name} should use " \
                     'a variable rather than a literal value')
    end

  private

    def ignored_value?(value)
      value.respond_to?(:value) &&
        IGNORED_VALUES.include?(value.value.to_s)
    end
  end
end
