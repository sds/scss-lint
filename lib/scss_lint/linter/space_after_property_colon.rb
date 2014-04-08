module SCSSLint
  # Checks for spaces following the colon that separates a property's name from
  # its value.
  class Linter::SpaceAfterPropertyColon < Linter
    include LinterRegistry

    MINIMUM_SPACES_AFTER_COLON = 1

    def visit_rule(node)
      children = node.children.select do |child|
        child.is_a?(Sass::Tree::PropNode)
      end

      max_length = max_property_length(children) + MINIMUM_SPACES_AFTER_COLON

      children.each do |child|
        check_node(child, max_length)
      end

      yield # Continue linting children
    end

  private

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

    def max_property_length(children)
      children.map do |child|
        child.name.first.length
      end.max
    end

    def check_node(node, max_length)
      property_length = node.name.first.length
      spaces = spaces_after_colon(node)

      if config['allow_extra_spaces']
        if property_length + spaces != max_length
          add_lint node, 'Colon after property should be followed by ' <<
                          "#{pluralize(max_length - property_length, 'space')} " <<
                          "to align all values"
        end
      elsif spaces != MINIMUM_SPACES_AFTER_COLON
        add_lint node, 'Colon after property should be followed by ' <<
                       pluralize(MINIMUM_SPACES_AFTER_COLON, 'space') <<
                       " instead of #{pluralize(spaces, 'space')}"
      end
    end
  end
end
