module SCSSLint
  # Checks for the presence of a single space before an opening brace.
  class Linter::SpaceBeforeBrace < Linter
    include LinterRegistry

    def visit_root(node)
      engine.lines.each_with_index do |line, index|
        line.scan /(?<![^ ] )\{$/ do |match|
          @lints << Lint.new(engine.filename, index + 1, description)
        end
      end
    end

    def description
      'Opening curly braces ({) must be preceded by one space'
    end
  end
end
