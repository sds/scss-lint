module SCSSLint
  # Reports the use of literals for specified properties where
  # variables are prefered
  class Linter::UseVariablesForProperties < Linter
    include LinterRegistry

    def visit_root(_node)
      @properties = Set.new(config['properties'])
      yield if @properties.any?
    end

    def visit_prop(node)
      property_name = node.name.join
      return unless @properties.include? property_name
      return if node.children.first.is_a?(Sass::Script::Tree::Variable)

      add_lint(node, "Property #{property_name} should use " \
                     "a variable rather than a literal value")
    end
  end
end
