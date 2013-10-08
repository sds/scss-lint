module SCSSLint
  class Linter::DuplicateProperty < Linter
    include LinterRegistry

    def visit_rule(node)
      properties = node.children
                       .select { |child| child.is_a?(Sass::Tree::PropNode) }
                       .reject { |prop| prop.name.any? { |item| item.is_a?(Sass::Script::Node) } }

      prop_names = {}

      properties.each do |prop|
        name = prop.name.join

        if existing_prop = prop_names[name]
          add_lint(prop, "Property '#{name}' already defined on line #{existing_prop.line}")
        else
          prop_names[name] = prop
        end
      end
    end
  end
end
