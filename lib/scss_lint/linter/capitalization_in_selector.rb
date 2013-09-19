module SCSSLint
  class Linter::CapitalizationInSelector < Linter
    include LinterRegistry

    def visit_attribute(attribute)
      check(attribute)
    end

    def visit_class(klass)
      check(klass)
    end

    def visit_element(element)
      check(element)
    end

    def visit_id(id)
      check(id)
    end

    def visit_placeholder(placeholder)
      check(placeholder)
    end

    def visit_pseudo(pseudo)
      check(pseudo, 'Pseudo-selector')
    end

  private

    def check(node, selector_name = nil)
      name = node.name.join
      if name =~ /[A-Z]/
        selector_name ||= node.class.name.split('::').last
        add_lint(node, "#{selector_name} `#{name}` in selector should be " <<
                       "written in all lowercase as `#{name.downcase}`")
      end
    end
  end
end
