module SCSSLint
  class Linter::DeclaredName < Linter
    include LinterRegistry

    def visit_function(node)
      check(node, 'function')
      yield # Continue into content block of this function definition
    end

    def visit_mixindef(node)
      check(node, 'mixin')
      yield # Continue into content block of this mixin definition
    end

    def visit_variable(node)
      check(node, 'variable')
      yield # Continue into expression tree for this variable definition
    end

  private

    def check(node, node_type)
      if node_has_bad_name?(node)
        fixed_name = node.name.downcase.gsub(/_/, '-')

        add_lint(node, "Name of #{node_type} `#{node.name}` should " <<
                       "be written in lowercase as `#{fixed_name}`")
      end
    end
  end
end
