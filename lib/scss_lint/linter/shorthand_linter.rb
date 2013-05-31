require 'sass'

module SCSSLint
  class Linter::ShorthandLinter < Linter
    include LinterRegistry

    def visit_prop(node)
      return unless SHORTHANDABLE_PROPERTIES.include? node.name.first.to_s

      case node.value
      when Sass::Script::List
        items = node.value.children
        if (2..4).member?(items.count)
          add_lint(node) unless valid_shorthand?(*items.map(&:to_sass))
        end
      when Sass::Script::String
        if node.value.to_sass.strip =~ /\A(\S+\s+\S+(\s+\S+){0,2})\Z/
          add_lint(node) unless valid_shorthand?(*$1.split(/\s+/))
        end
      end
    end

    def description
      'Property values should use the shortest shorthand syntax allowed'
    end

  private

    SHORTHANDABLE_PROPERTIES = %w[border-color
                                  border-radius
                                  border-style
                                  border-width
                                  margin
                                  padding]

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
