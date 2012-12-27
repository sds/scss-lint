require 'sass'

module SCSSLint
  class Linter::PropertyFormatLinter < Linter
    include LinterRegistry

    class << self
      def run(engine)
        lints = []
        engine.tree.each do |node|
          if node.is_a?(Sass::Tree::PropNode)
            lints << check_property_format(node, engine.lines[node.line - 1]) if node.line
          end
        end
        lints.compact
      end

      def description
        'Property declarations should always be on one line of the form ' <<
        '`property-name: value;`'
      end

    private

      def check_property_format(prop_node, line)
        return create_lint(prop_node) unless line =~ /^\s*[\w-]+: \S[^;]*(?<!\s);/
      end
    end
  end
end
