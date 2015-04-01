require 'pry'
module SCSSLint
  # Check for pixel value usage
  class Linter::PropertyUnits < Linter
    include LinterRegistry

    def visit_prop(node)
      @global_allowed = config['global'].to_set
      @properties = properties config
      property = node.value.value.to_s
      name = node_name node
      units = property.scan /[a-zA-Z%]+/ix

      return if units.empty?

      not_allowed = any_units_not_allowed_globally? units

      unless @properties.key? name
        add_lint(node, "Units are not allowed globally: #{not_allowed.join(' ')}") unless not_allowed.empty?
        return
      end

      not_allowed = any_units_not_allowed_on_property? units, name
      unless not_allowed.empty?
        return add_lint(node, "Units are not allowed on #{name}: #{not_allowed.join(' ')}")
      end
    end

    private

    def any_units_not_allowed_globally? units
      return any_units_not_allowed? units, @global_allowed
    end

    def any_units_not_allowed_on_property? units, property
      return any_units_not_allowed? units, @properties[property]
    end

    def any_units_not_allowed? units, allowed
      return units.select {|unit| !allowed.include?(unit)}
    end

    def properties config
      output = {}
      config['properties'].to_set.each do |prop|
        prop.keys.each {|key| output[dash_to_underscore(key)] = prop[key]}
      end
      return output
    end

    def node_name node
      return dash_to_underscore node.name.join
    end

    def dash_to_underscore str
      return str.sub('-', '_')
    end

  end
end