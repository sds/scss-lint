module SCSSLint
  # Checks the declaration order of properties.
  class Linter::PropertySortOrder < Linter
    include LinterRegistry

    def visit_root(_node)
      @preferred_order = extract_preferred_order_from_config
      yield
    end

    def visit_rule(node)
      sortable_props = node.children.select do |child|
        child.is_a?(Sass::Tree::PropNode) && !ignore_property?(child)
      end

      sortable_prop_info = sortable_props
        .map { |child| child.name.join }
        .map do |name|
          /^(?<vendor>-\w+(-osx)?-)?(?<property>.+)/ =~ name
          { name: name, vendor: vendor, property: property }
        end

      sorted_props = sortable_prop_info
        .sort { |a, b| compare_properties(a, b) }

      sorted_props.each_with_index do |prop, index|
        next unless prop != sortable_prop_info[index]

        add_lint(sortable_props[index], lint_message)
        break
      end

      yield # Continue linting children
    end

  private

    # Compares two properties which can contain a vendor prefix. It allows for a
    # sort order like:
    #
    #   p {
    #     border: ...
    #     -moz-border-radius: ...
    #     -o-border-radius: ...
    #     -webkit-border-radius: ...
    #     border-radius: ...
    #     color: ...
    #   }
    #
    # ...where vendor-prefixed properties come before the standard property, and
    # are ordered amongst themselves by vendor prefix.
    def compare_properties(a, b)
      if a[:property] == b[:property]
        compare_by_vendor(a, b)
      else
        if @preferred_order
          compare_by_order(a, b, @preferred_order)
        else
          a[:property] <=> b[:property]
        end
      end
    end

    def compare_by_vendor(a, b)
      if a[:vendor] && b[:vendor]
        a[:vendor] <=> b[:vendor]
      elsif a[:vendor]
        -1
      elsif b[:vendor]
        1
      else
        0
      end
    end

    def compare_by_order(a, b, order)
      (order.index(a[:property]) || Float::INFINITY) <=>
        (order.index(b[:property]) || Float::INFINITY)
    end

    def extract_preferred_order_from_config
      case config['order']
      when nil
        nil # No custom order specified
      when Array
        config['order']
      when String
        begin
          file = File.open(File.join(SCSS_LINT_DATA,
                                     'property-sort-orders',
                                     "#{config['order']}.txt"))
          file.read.split("\n").reject { |line| line =~ /^(#|\s*$)/ }
        rescue Errno::ENOENT
          raise SCSSLint::LinterError,
                "Preset property sort order '#{config['order']}' does not exist"
        end
      else
        raise SCSSLint::LinterError,
              'Invalid property sort order specified -- must be the name of a '\
              'preset or an array of strings'
      end
    end

    # Return whether to ignore a property in the sort order.
    #
    # This includes:
    # - properties containing interpolation
    # - properties not explicitly defined in the sort order (if ignore_unspecified is set)
    def ignore_property?(prop_node)
      return true if prop_node.name.any? { |part| !part.is_a?(String) }

      config['ignored_unspecified'] &&
        @preferred_order &&
        !@preferred_order.include?(prop_node.name.join)
    end

    def preset_order?
      config['order'].is_a?(String)
    end

    def lint_message
      if preset_order?
        "Properties should be sorted according to the #{config['order']} sort order"
      elsif @preferred_order
        'Properties should be sorted according to the custom order ' \
        'specified by the configuration'
      else
        'Properties should be sorted in order, with vendor-prefixed ' \
        'extensions before the standardized CSS property'
      end
    end
  end
end
