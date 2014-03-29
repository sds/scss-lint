module SCSSLint
  # Checks for the presence of a single space before an opening brace.
  class Linter::SpaceBeforeBrace < Linter
    include LinterRegistry

    def visit_root(node)
      engine.lines.each_with_index do |line, index|
        line.scan /[^"#](?<![^ ] )\{/ do |match|
          add_lint(index + 1, 'Opening curly braces ({) should be preceded by one space')
        end
      end
    end
  end
end
