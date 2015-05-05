module SCSSLint
  # Checks for BEM selectors with more elements than a specified maximum number.
  class Linter::BemDepth < Linter
    include LinterRegistry

    def visit_root(_node)
      @max_elements = config['max_elements']
      yield # Continue linting children
    end

    def visit_class(klass)
      check_depth(klass, 'selectors')
    end

    def visit_placeholder(placeholder)
      check_depth(placeholder, 'placeholders')
    end

  private

    def check_depth(node, plural_type)
      selector = node.name
      parts = selector.split('__')
      num_elements = (parts[1..-1] || []).length
      if num_elements > @max_elements
        add_lint(node, "BEM #{plural_type} should have no more than #{pluralize(@max_elements, 'element')}, but had #{num_elements}")
      end
    end

  end
end
