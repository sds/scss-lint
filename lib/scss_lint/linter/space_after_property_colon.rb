module SCSSLint
  # Checks for spaces following the colon that separates a property's name from
  # its value.
  class Linter::SpaceAfterPropertyColon < Linter
    include LinterRegistry

    EXPECTED_SPACES_AFTER_COLON = 1

    def visit_prop(node)
      spaces = spaces_after_colon(node)

      if spaces != EXPECTED_SPACES_AFTER_COLON
        add_lint node, 'Colon after property should be followed by ' <<
                       "#{pluralize(EXPECTED_SPACES_AFTER_COLON, 'space')} instead of " <<
                       pluralize(spaces, 'space')
      end
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
  end
end
