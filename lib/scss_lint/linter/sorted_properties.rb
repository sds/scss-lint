module SCSSLint
  class Linter::SortedProperties < Linter
    include LinterRegistry

    def visit_rule(node)
      # Ignore properties that contain interpolation
      sortable_props = node.children.select do |child|
        child.is_a?(Sass::Tree::PropNode) &&
          child.name.all? { |part| part.is_a?(String) }
      end

      sortable_prop_names = sortable_props.map { |child| child.name.join }

      sorted_prop_names = sortable_prop_names.map do |name|
        /^(?<vendor>-\w+-)?(?<property>.+)/ =~ name
        { name: name, vendor: vendor, property: property }
      end.sort { |a, b| compare_properties(a, b) }
         .map { |fields| fields[:name] }

      sorted_prop_names.each_with_index do |name, index|
        # Report the first property out of order with the sorted list
        if name != sortable_prop_names[index]
          add_lint(sortable_props[index])
          break
        end
      end

      yield # Continue linting children
    end

    def description
      'Properties should be sorted in alphabetical order, with ' <<
      'vendor-prefixed extensions before the standardized CSS property'
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
        if a[:vendor] && b[:vendor]
          a[:vendor] <=> b[:vendor]
        elsif a[:vendor]
          -1
        elsif b[:vendor]
          1
        else
          0
        end
      else
        a[:property] <=> b[:property]
      end
    end
  end
end
