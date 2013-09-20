module SCSSLint
  class Linter::ZeroUnit < Linter
    include LinterRegistry

    def visit_prop(node)
      if node.value.is_a?(Sass::Script::String) &&
         node.value.type == :identifier

        node.value.value.scan(/\b(0[a-z]+)\b/i) do |match|
          add_lint(node, MESSAGE_FORMAT % match.first)
        end
      end

      yield # Continue visiting children
    end

    def visit_script_number(node)
      if node.value == 0 && !node.unitless?
        add_lint(node, MESSAGE_FORMAT % node.original)
      end
    end

  private

    MESSAGE_FORMAT = '`%s` should be written without units as `0`'
  end
end
