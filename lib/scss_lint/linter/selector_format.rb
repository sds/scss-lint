module SCSSLint
  # Checks that selector names use a specified convention
  class Linter::SelectorFormat < Linter
    include LinterRegistry

    def visit_root(_node)
      @ignored_names = Array(config['ignored_names']).to_set
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
      check(pseudo) unless @ignored_types.include?('pseudo-selector')
    end

  private

    def check(node)
      name = node.name

      return if @ignored_names.include?(name)
      return unless violation = violated_convention(name)

      add_lint(node, "Selector `#{name}` should be " \
                     "written #{violation[:explanation]}")
    end

    CONVENTIONS = {
      'hyphenated_lowercase' => {
        explanation: 'in lowercase with hyphens',
        validator: ->(name) { name !~ /[^\-a-z0-9]/ },
      },
      'snake_case' => {
        explanation: 'in lowercase with underscores',
        validator: ->(name) { name !~ /[^_a-z0-9]/ },
      },
      'camel_case' => {
        explanation: 'has no spaces with capitalized words except first',
        validator: ->(name) { name =~ /^[a-z][a-zA-Z0-9]*$/ },
      },
      'BEM' => {
        explanation: 'in BEM (Block Element Modifier) format',
        validator: ->(name) { name !~ /[A-Z]|-{3}|_{3}|[^_]_[^_]/ },
      },
    }

    # Checks the given name and returns the violated convention if it failed.
    def violated_convention(name_string)
      convention_name = config['convention'] || 'hyphenated_lowercase'

      convention = CONVENTIONS[convention_name] || {
        explanation: "must match regex /#{convention_name}/",
        validator: ->(name) { name =~ /#{convention_name}/ }
      }

      convention unless convention[:validator].call(name_string)
    end
  end
end
