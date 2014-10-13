module SCSSLint
  # Checks for nesting depths
  class Linter::NestingDepth < Linter
    include LinterRegistry

    def visit_root(_node)
      @max_depth = config['max_depth']
      @depth = 0
      yield # Continue linting children
    end

    def visit_rule(node)
      if !node.node_parent.respond_to?(:parsed_rules)
        # RootNodes will reset depth to zero
        @depth = 0
      elsif node.node_parent == @last_parent
        # reset to last depth if node is a sibling
        @depth = @last_depth
      else
        @depth += 1
      end

      if @depth > @max_depth
        add_lint(node.parsed_rules, 'Nesting should be no greater than ' \
                                    "#{@max_depth}, but was #{@depth}")
      end

      yield # Continue linting children
      @last_parent = node.node_parent
      @last_depth = @depth
    end
  end
end
