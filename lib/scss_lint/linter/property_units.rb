module SCSSLint
  # Check for allowed units
  class Linter::PropertyUnits < Linter
    include LinterRegistry

    def visit_prop(node)
      @node = node
      @global_allowed = config['global'].to_set
      @properties = config['properties']
      @property = node.name.join
      @units = node.value.value.to_s.scan(/[a-zA-Z%]+/ix)

      return if @units.empty?

      global_allows_ok? && property_allows_ok?
    end

  private

    def global_allows_ok?
      not_allowed = units_not_allowed_globally
      unless property_units_defined?
        unless not_allowed.empty?
          add_lint(@node, "Units are not allowed globally: #{not_allowed.join(' ')}")
        end
        return false
      end
      true
    end

    def property_allows_ok?
      not_allowed = units_not_allowed_on_property
      unless not_allowed.empty?
        add_lint(@node, "Units are not allowed on #{@property}: #{not_allowed.join(' ')}")
        return false
      end
      true
    end

    def units_not_allowed_globally
      units_not_allowed @units, @global_allowed
    end

    def units_not_allowed_on_property
      units_not_allowed @units, @properties[property_key]
    end

    def units_not_allowed(units, allowed)
      units.select { |unit| !allowed.include?(unit) }
    end

    def property_units_defined?
      @properties.key? property_key
    end

    def property_key
      @property.gsub('-', '_')
    end
  end
end
