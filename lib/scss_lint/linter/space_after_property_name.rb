module SCSSLint
  # Checks for spaces following the name of a property and before the colon
  # separating the property's name from its value.
  class Linter::SpaceAfterPropertyName < Linter
    include LinterRegistry

    def visit_prop(node)
      return unless character_at(node.name_source_range.end_pos) != ':'
      add_lint node, 'Property name should be immediately followed by a colon'
    end
  end
end
