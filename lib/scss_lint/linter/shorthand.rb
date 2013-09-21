module SCSSLint
  class Linter::Shorthand < Linter
    include LinterRegistry

    def visit_prop(node)
      return unless SHORTHANDABLE_PROPERTIES.include?(node.name.join)

      case node.value
      when Sass::Script::List
        check_script_list(node.value)
      when Sass::Script::String
        check_script_string(node.value)
      end
    end

    def description
      'Property values should use the shortest shorthand syntax allowed'
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

    def check_script_list(list)
      items = list.children

      if (2..4).member?(items.count)
        add_lint(list) unless valid_shorthand?(*items.map(&:to_sass))
      end
    end

    def check_script_string(script_string)
      return unless script_string.type == :identifier

      if script_string.value.strip =~ /\A(\S+\s+\S+(\s+\S+){0,2})\z/
        add_lint(script_string) unless valid_shorthand?(*$1.split(/\s+/))
      end
    end

    def valid_shorthand?(top, right, bottom = nil, left = nil)
      if top == right && right == bottom && bottom == left
        false
      elsif top == right && bottom.nil? && left.nil?
        false
      elsif top == bottom && right == left
        false
      elsif top == bottom && left.nil?
        false
      elsif right == left
        false
      else
        true
      end
    end
  end
end
