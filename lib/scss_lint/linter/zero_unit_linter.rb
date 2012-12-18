require 'sass'

module SCSSLint
  class Linter::ZeroUnitLinter < Linter
    include LinterRegistry

    class << self
      def run(engine)
        lints = []
        engine.tree.each do |node|
          if node.is_a?(Sass::Tree::PropNode)
            lints << check_zero_unit(node, engine.lines[node.line - 1]) if node.line
          end
        end
        lints.compact
      end

      def description
        'Properties with a value of zero should be unit-less'
      end

    private

      def check_zero_unit(prop_node, line)
        return create_lint(prop_node) if line =~ /^\s*[\w-]+:\s*0[a-z]+;$/i
      end
    end
  end
end
