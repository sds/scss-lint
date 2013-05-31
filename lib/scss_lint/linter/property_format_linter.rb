require 'sass'

module SCSSLint
  class Linter::PropertyFormatLinter < Linter
    include LinterRegistry

    def visit_prop(node)
      line = engine.lines[node.line - 1] if node.line

      add_lint(node) unless line =~ PROPERTY_RE
    end

    def description
      'Property declarations should always be on one line of the form ' <<
      '`name: value;` or `name: [value] {` ' <<
      '(are you missing a trailing semi-colon?)'
    end

  private

    VALUE_RE = %r{(\S+\s)*\S+} # eg. "10px", "10px normal"
    PROPERTY_RE = %r{
      ^\s*[^:]+(?<!\s):\s       # property name, colon not preceded by a space, one space
        (                       # followed by
          #{VALUE_RE};          # property and terminating semi-colon eg. a b c;
          |                     # or
          ((#{VALUE_RE}\s)?\{)  # nested property, optional value, trailing curly
        )
    }x
  end
end
