module SCSSLint
  # Checks for capitalized letters in IDs, classes, types, etc. in selectors.
  class Linter::CapitalizationInSelector < Linter
    include LinterRegistry

    def visit_root(_node)
      @ignored_types = Array(config['ignored_types']).to_set
      yield
    end

    def visit_attribute(attribute)
      check(attribute) unless @ignored_types.include?('attribute')
    end

    def visit_class(klass)
      check(klass) unless @ignored_types.include?('class')
    end

    def visit_element(element)
      check(element) unless @ignored_types.include?('element')
    end

    def visit_id(id)
      check(id) unless @ignored_types.include?('id')
    end

    def visit_placeholder(placeholder)
      check(placeholder) unless @ignored_types.include?('placeholder')
    end

    def visit_pseudo(pseudo)
      check(pseudo, 'Pseudo-selector') unless @ignored_types.include?('pseudo-selector')
    end

  private

    def check(node, selector_name = nil)
      name = node.name.join
      return unless name =~ /[A-Z]/

      selector_name ||= node.class.name.split('::').last
      add_lint(node, "#{selector_name} `#{name}` in selector should be " \
                     "written in all lowercase as `#{name.downcase}`")
    end
  end
end
