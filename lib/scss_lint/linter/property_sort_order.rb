module SCSSLint
  # Checks the declaration order of properties.
  class Linter::PropertySortOrder < Linter
    include LinterRegistry

    def visit_rule(node)
      # Ignore properties that contain interpolation
      sortable_props = node.children.select do |child|
        child.is_a?(Sass::Tree::PropNode) &&
          child.name.all? { |part| part.is_a?(String) }
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
        if prop != sortable_prop_info[index]
          add_lint(sortable_props[index], MESSAGE)
          break
        end
      end

      yield # Continue linting children
    end

  private

    MESSAGE = 'Properties should be sorted in order, with vendor-prefixed ' \
              'extensions before the standardized CSS property'

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
        if config['order']
          compare_by_order(a, b, config['order'])
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
  end
end
