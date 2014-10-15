module SCSSLint
  # Checks for rule sets nested deeper than a specified maximum depth.
  class Linter::NestingDepth < Linter
    include LinterRegistry

    def visit_root(_node)
      @max_depth = config['max_depth']
      @depth = 1
      yield # Continue linting children
    end

    def visit_rule(node)
      if @depth > @max_depth
        add_lint(node, "Nesting should be no greater than #{@max_depth}, but was #{@depth}")
      else
        # Only continue if we didn't exceed the max depth already (this makes
        # the lint less noisy)
        @depth += 1
        yield # Continue linting children
        @depth -= 1
      end
    end
  end
end
