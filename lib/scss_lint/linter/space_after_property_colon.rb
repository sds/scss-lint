module SCSSLint
  # Checks for spaces following the colon that separates a property's name from
  # its value.
  class Linter::SpaceAfterPropertyColon < Linter
    include LinterRegistry

    def visit_prop(node)
      spaces = spaces_after_colon(node)

      if config['allow_extra_spaces']
        if spaces == 0
          add_lint node, 'Colon after property should be followed by ' <<
                         "at least #{pluralize(1, 'space')} "
        end
      else
        if spaces != 1
          add_lint node, 'Colon after property should be followed by ' <<
                         "#{pluralize(1, 'space')} instead of " <<
                         pluralize(spaces, 'space')
        end
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
