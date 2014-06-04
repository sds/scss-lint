module SCSSLint
  # Checks for spaces following the colon that separates a property's name from
  # its value.
  class Linter::SpaceAfterPropertyColon < Linter
    include LinterRegistry

    def visit_rule(node)
      if config['style'] == 'aligned'
        check_properties_alignment(node)
      end

      yield # Continue linting children
    end

    def visit_prop(node)
      spaces = spaces_after_colon(node)

      case config['style']
      when 'no_space'
        check_for_no_spaces(node, spaces)
      when 'one_space'
        check_for_one_space(node, spaces)
      when 'at_least_one_space'
        check_for_at_least_one_space(node, spaces)
      end
    end

  private

    def check_for_no_spaces(node, spaces)
      if spaces > 0
        add_lint(node, 'Colon after property should not be followed by any spaces')
      end
    end

    def check_for_one_space(node, spaces)
      if spaces != 1
        add_lint(node, 'Colon after property should be followed by one space')
      end
    end

    def check_for_at_least_one_space(node, spaces)
      if spaces < 1
        add_lint(node, 'Colon after property should be followed by at least one space')
      end
    end

    def check_properties_alignment(rule_node)
      properties = rule_node.children.select { |node| node.is_a?(Sass::Tree::PropNode) }

      properties.each_slice(2) do |prop1, prop2|
        next unless prop2
        next unless value_offset(prop1) != value_offset(prop2)
        add_lint(prop1, 'Property values should be aligned')
        break
      end
    end

    # Offset of value for property
    def value_offset(prop)
      src_range = prop.name_source_range
      src_range.start_pos.offset +
        (src_range.end_pos.offset - src_range.start_pos.offset) +
        spaces_after_colon(prop)
    end

    def spaces_after_colon(node)
      spaces = 0
      offset = 1

      # Handle quirk where Sass parser doesn't include colon in source range
      # when property name is followed by spaces
      if character_at(node.name_source_range.end_pos, offset) == ':'
        offset += 1
      end

      while character_at(node.name_source_range.end_pos, offset) == ' '
        spaces += 1
        offset += 1
      end

      spaces
    end
  end
end
