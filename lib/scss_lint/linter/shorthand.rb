module SCSSLint
  # Checks for the use of the shortest form for properties that can be written
  # in shorthand.
  class Linter::Shorthand < Linter
    include LinterRegistry

    def visit_prop(node)
      property_name = node.name.join
      return unless SHORTHANDABLE_PROPERTIES.include?(property_name)

      case node.value
      when Sass::Script::Tree::Literal
        check_script_literal(property_name, node.value)
      when Sass::Script::Tree::ListLiteral
        check_script_list(property_name, node.value)
      end
    end

  private

    SHORTHANDABLE_PROPERTIES = %w[
      border-color
      border-radius
      border-style
      border-width
      margin
      padding
    ]

    def check_script_list(prop, list)
      check_shorthand(prop, list, list.children.map(&:to_sass))
    end

    def check_script_literal(prop, literal)
      value = literal.value

      # HACK: node_parent may not be initialized at this point, so we need to
      # set it ourselves
      value.node_parent = literal

      if value.is_a?(Sass::Script::Value::String)
        check_script_string(prop, value)
      end
    end

    def check_script_string(prop, script_string)
      return unless script_string.type == :identifier

      if values = script_string.value.strip[/\A(\S+\s+\S+(\s+\S+){0,2})\z/, 1]
        check_shorthand(prop, script_string, values.split)
      end
    end

    def check_shorthand(prop, node, values)
      return unless (2..4).member?(values.count)

      shortest_form = condensed_shorthand(*values)
      return if values == shortest_form

      add_lint(node, "Shorthand form for property `#{prop}` should be " \
                     "written more concisely as `#{shortest_form.join(' ')}` " \
                     "instead of `#{values.join(' ')}`")
    end

    def condensed_shorthand(top, right, bottom = nil, left = nil)
      if can_condense_to_one_value(top, right, bottom, left)
        [top]
      elsif can_condense_to_two_values(top, right, bottom, left)
        [top, right]
      elsif right == left
        [top, right, bottom]
      else
        [top, right, bottom, left].compact
      end
    end

    def can_condense_to_one_value(top, right, bottom, left)
      if top == right
        top == bottom && (bottom == left || left.nil?) ||
          bottom.nil? && left.nil?
      end
    end

    def can_condense_to_two_values(top, right, bottom, left)
      top == bottom && right == left ||
        top == bottom && left.nil? && top != right
    end
  end
end
