# Ignore documentation lints as these aren't original implementations.
# rubocop:disable Documentation

module Sass::Script
  # Redefine some of the lexer helpers in order to store the original string
  # with the created object so that the original string can be inspected rather
  # than a typically normalized version.
  class Lexer
    def color
      return unless color_string = scan(REGULAR_EXPRESSIONS[:color])

      unless [4, 7].include?(color_string.length)
        raise ::Sass::SyntaxError,
              "Colors must have either three or six digits: '#{color_string}'"
      end

      [:color, Value::Color.from_string(color_string)]
    end
  end

  class Parser
    # We redefine the ident parser to specially handle color keywords.
    def ident
      return funcall unless @lexer.peek && @lexer.peek.type == :ident
      return if @stop_at && @stop_at.include?(@lexer.peek.value)

      name = @lexer.next
      if (color = Value::Color::COLOR_NAMES[name.value.downcase])
        return literal_node(Value::Color.from_string(name.value, color), name.source_range)
      end
      literal_node(Value::String.new(name.value, :identifier), name.source_range)
    end
  end

  # Since the Sass library is already loaded at this point.
  # Define the `node_name` and `visit_method` class methods for each Sass Script
  # parse tree node type so that our custom visitor can seamless traverse the
  # tree.
  #
  # This would be easier if we could just define an `inherited` callback, but
  # that won't work since the Sass library will have already been loaded before
  # this code gets loaded, so the `inherited` callback won't be fired.
  #
  # Thus we are left to manually define the methods for each type explicitly.
  {
    'Value' => %w[ArgList Bool Color List Map Null Number String],
    'Tree'  => %w[Funcall Interpolation ListLiteral Literal MapLiteral
                  Operation StringInterpolation UnaryOperation Variable],
  }.each do |namespace, types|
    types.each do |type|
      node_name = type.downcase

      eval <<-DECL
        class #{namespace}::#{type}
          def self.node_name
            :script_#{node_name}
          end

          def self.visit_method
            :visit_script_#{node_name}
          end
        end
      DECL
    end
  end

  class Value::Base
    attr_accessor :node_parent

    def children
      []
    end

    def line
      @line || (node_parent && node_parent.line)
    end

    def source_range
      @source_range || (node_parent && node_parent.source_range)
    end
  end

  # When linting colors, it's convenient to be able to inspect the original
  # color string. This adds an attribute to the Color to keep track of the
  # original string and provides a method which the modified lexer can use to
  # set it.
  class Value::Color
    attr_accessor :original_string

    def self.from_string(string, rgb = nil)
      unless rgb
        rgb = string.scan(/^#(..?)(..?)(..?)$/).
                     first.
                     map { |hex| hex.ljust(2, hex).to_i(16) }
      end

      color = new(rgb, false)
      color.original_string = string
      color
    end
  end

  class Value::Number
    attr_accessor :original_string
  end

  # Contains extensions of Sass::Script::Tree::Nodes to add support for
  # accessing various parts of the parse tree not provided out-of-the-box.
  module Tree
    class Node
      attr_accessor :node_parent
    end

    class Literal
      # Literals wrap their underlying values. For sake of convenience, consider
      # the wrapped value a child of the Literal.
      def children
        [value]
      end
    end
  end
end
