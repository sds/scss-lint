# Contains extensions of Sass::Script::Nodes to add support for accessing
# various parts of the parse tree not provided out-of-the-box.
module Sass::Script
  class Variable
    # When accessing keyword arguments, the Sass parser treats the underscored
    # name as canonical. Since this only matters during the compilation step, we
    # can safely override the behaviour to return the original name.
    def underscored_name
      @name
    end
  end

  # When linting colors, it's convenient to be able to inspect the original
  # color string. This adds an attribute to the Color to keep track of the
  # original string and provides a method which the modified lexer can use to
  # set it.
  class Color
    attr_accessor :original

    def self.from_string(string, rgb = nil)
      unless rgb
        rgb = string.scan(/^#(..?)(..?)(..?)$/).
                     first.
                     map { |hex| hex.ljust(2, hex).to_i(16) }
      end

      color = Color.new(rgb, false)
      color.original = string
      color
    end
  end

  class Lexer
    # We redefine the color lexer to store the original string with the created
    # `Color` object so that we can inspect the original string before it is
    # normalized.
    #
    # This is an adapted version from the original Sass source code.
    def color
      return unless color_string = scan(REGULAR_EXPRESSIONS[:color])

      unless [4, 7].include?(color_string.length)
        raise ::Sass::SyntaxError,
              "Colors must have either three or six digits: '#{color_string}'"
      end

      [:color, Color.from_string(color_string)]
    end
  end

  class Parser
    # We redefine the ident parser to specially handle color keywords.
    def ident
      return funcall unless @lexer.peek && @lexer.peek.type == :ident
      return if @stop_at && @stop_at.include?(@lexer.peek.value)

      name = @lexer.next
      if color = Color::COLOR_NAMES[name.value.downcase]
        return node(Color.from_string(name.value, color))
      end
      node(Sass::Script::String.new(name.value, :identifier))
    end
  end
end
