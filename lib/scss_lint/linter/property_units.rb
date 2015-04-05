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
      units = node.value.value.to_s.scan(/[a-zA-Z%]+/ix)
      return if units.empty?

      global_allows_ok?(node, property, units) && property_allows_ok?(node, property, units)
    end

  private

    def global_allows_ok?(node, property, units)
      not_allowed = units_not_allowed_globally(units)
      unless property_units_defined?(property)
        unless not_allowed.empty?
          add_lint(node, "Units are not allowed globally: #{not_allowed.join(' ')}")
        end
        return false
      end
      true
    end

    def property_allows_ok?(node, property, units)
      not_allowed = units_not_allowed_on_property(property, units)
      unless not_allowed.empty?
        add_lint(node, "Units are not allowed on #{property}: #{not_allowed.join(' ')}")
        return false
      end
      true
    end

    def units_not_allowed_globally(units)
      units_not_allowed units, @globally_allowed_units
    end

    def units_not_allowed_on_property(property, units)
      units_not_allowed units, @allowed_units_for_property[property]
    end

    def units_not_allowed(units, allowed)
      units.select { |unit| !allowed.include?(unit) }
    end

    def property_units_defined?(property)
      @allowed_units_for_property.key?(property)
    end
  end
end
