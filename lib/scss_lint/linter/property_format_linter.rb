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
        '`name: value;` or `name: [value] {`'
      end

    private

      VALUE_RE = %r{(\S+\s)*\S+} # eg. "10px", "10px normal"
      PROPERTY_RE = %r{
        ^\s*[\w-]+:\s           # property name, colon, one space
          (                     # followed by
          #{VALUE_RE};          # property and terminating semi-colon eg. a b c;
          |                     # or
          ((#{VALUE_RE}\s)?\{)  # nested property, optional value, trailing curly
          )
      }x

      def check_property_format(prop_node, line)
        return create_lint(prop_node) unless line =~ PROPERTY_RE
      end
    end
  end
end
