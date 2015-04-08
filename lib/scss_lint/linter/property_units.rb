module SCSSLint
  # Check for allowed units
  class Linter::PropertyUnits < Linter
    include LinterRegistry

    def visit_root(_node)
      @globally_allowed_units = config['global'].to_set
      @allowed_units_for_property = config['properties']

      yield # Continue linting children
    end

    def visit_prop(node)
      property = node.name.join

      # Handle nested properties by ensuring the full name is extracted
      if @nested_under
        property = "#{@nested_under}-#{property}"
      end

      if node.value.respond_to?(:value) &&
         units = node.value.value.to_s[/(?:^|\s)(?:\d+|\d*\.?\d+)([a-z%]+)/i, 1]
        check_units(node, property, units)
      end

      @nested_under = property
      yield # Continue linting nested properties
      @nested_under = nil
    end

  private

    # Checks if a property value's units are allowed.
    #
    # @param node [Sass::Tree::Node]
    # @param property [String]
    # @param units [String]
    def check_units(node, property, units)
      allowed_units = allowed_units_for_property(property)
      return if allowed_units.include?(units)

      add_lint(node,
               "#{units} units not allowed on `#{property}`; must be one of " \
               "(#{allowed_units.to_a.sort.join(', ')})")
    end

    # Return the list of allowed units for a property.
    #
    # @param property [String]
    # @return Array<String>
    def allowed_units_for_property(property)
      if @allowed_units_for_property.key?(property)
        @allowed_units_for_property[property]
      else
        @globally_allowed_units
      end
    end
  end
end
