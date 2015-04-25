module SCSSLint
  # Checks that selectors in CSS Modules (https://github.com/gilbox/css-bliss#module) use a specified convention
  class Linter::Bliss::Module < Linter::Bliss
    include LinterRegistry

    def visit_root(_node)
      @ignored_utility_class_prefixes = Array(config['ignored_utility_class_prefixes']).to_set
      yield
    end

    def visit_rule(node)
      return if config['allow_utility_direct_styling']
      return unless is_module

      node.parsed_rules.members.each { |rule|
        match = /(^|\s)\.([a-z]\S*)$/.match(rule.to_s)

        if match
          add_lint(node, "Class `#{match.captures[1]}` is used at the end of a descendant selector. Avoid styling utility or state classes directly from within a Module. https://github.com/gilbox/css-bliss/blob/master/solving-complexity.md#7-breaking-isolation")
        end
      }

      yield
    end

    def visit_attribute(attribute)
      return if config['allow_attribute_selector_in_module']
      return unless is_module

      add_lint(attribute, 'Avoid using attribute selectors. https://github.com/gilbox/css-bliss/blob/master/solving-complexity.md#7-breaking-isolation')
    end

    def visit_class(klass)
      return unless is_module

      unless config['allow_utility_classes_in_module']
        if /^[a-z]/.match(klass.name)
          unless @ignored_utility_class_prefixes.any? { |prefix| klass.name.start_with?(prefix) }
            add_lint(klass, "Class `#{klass.name}` is not allowed in the #{@module_name} module (use a module-namespaced class)")
          end
        end
      end

      if /^[A-Z]/.match(klass.name) && ! klass.name.start_with?(@module_name)
        add_lint(klass, "Class selector `#{klass.name}` is not allowed in the #{@module_name} module https://github.com/gilbox/css-bliss#encapsulation")
      end
    end

    def visit_element(element)
      return if config['allow_element_selector_in_module']
      return unless is_module

      add_lint(element, 'Avoid using element selectors. https://github.com/gilbox/css-bliss/blob/master/solving-complexity.md#7-breaking-isolation')
    end

    def visit_id(id)
      return if config['allow_id_selector_in_module']
      return unless is_module

      add_lint(id, 'Don\'t use id selectors in CSS Modules.')
    end

    def visit_prop(node)
      return unless is_module

      if node.node_parent.rule.include?(".#{@module_name}")
        name = node.name[0]
        unless config['allow_module_margin']
          if name.start_with?('margin')
            add_lint(node, 'A module should not define it\'s own margin, instead the parent element should define padding. https://github.com/gilbox/css-bliss#module')
          end
        end

        unless config['allow_module_width']
          if name == 'width'
            value = node.value
            if value.is_a?(Sass::Script::Tree::Literal) && /\d/.match("#{value.value}") && ! ['100%', '100vw'].include?("#{value.value}")
              add_lint(node, 'A module should not define it\'s own bespoke width, it should take up the full width of it\'s parent element. https://github.com/gilbox/css-bliss#module')
            end
          end
        end
      end
    end

  private
    def is_module

      # really just used for testing
      if config['module_name']
        @module_name = config['module_name']
        return true
      end

      match_module_file = (config['module_file_pattern'] || /[\/\\]_?([A-Z][a-zA-Z0-9]+)\.scss/).match(@engine.filename)
      return false unless match_module_file # not a module

      @module_name = match_module_file.captures[0]
      true
    end
  end
end
