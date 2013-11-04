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
        # HACK: node_parent may not be initialized at this point, so we need to
        # set it ourselves
        node.value.value.node_parent = node.value
        check_script_string(property_name, node.value.value)
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

      add_lint(node, "Shorthand form for property `#{prop}` should be " <<
                     "written more concisely as `#{shortest_form.join(' ')}` " <<
                     "instead of `#{values.join(' ')}`")
    end

    def condensed_shorthand(top, right, bottom = nil, left = nil)
      if top == right && right == bottom && bottom == left
        [top]
      elsif top == right && bottom.nil? && left.nil?
        [top]
      elsif top == bottom && right == left
        [top, right]
      elsif top == bottom && left.nil?
        top == right ? [top] : [top, right]
      elsif right == left
        [top, right, bottom]
      else
        [top, right, bottom, left].compact
      end
    end
  end
end
