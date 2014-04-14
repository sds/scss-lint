module SCSSLint
  # Checks for uses of properties where a Compass mixin would be preferred.
  class Linter::Compass::PropertyWithMixin < Linter::Compass
    include LinterRegistry

    def visit_prop(node)
      prop_name = node.name.join

      if PROPERTIES_WITH_MIXINS.include?(prop_name)
        add_lint node, "Use the Compass `#{prop_name}` mixin instead of the property"
      end

      if prop_name == "display" and node.value.value.to_s == "inline-block"
        add_lint node, "Use the Compass inline-block mixin instead of declaring 'display: inline-block'"
      end

    end

  private

    # Set of properties where the Compass mixin version is preferred
    PROPERTIES_WITH_MIXINS = %w[
      background-clip
      background-origin
      border-radius
      box-shadow
      box-sizing
      opacity
      text-shadow
      transform
    ].to_set
  end
end
