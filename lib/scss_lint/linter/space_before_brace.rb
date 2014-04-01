module SCSSLint
  # Checks for the presence of a single space before an opening brace.
  class Linter::SpaceBeforeBrace < Linter
    include LinterRegistry

    def visit_root(node)
      engine.lines.each_with_index do |line, index|

        if config['allow_extra_spaces'] && node_on_single_line(node)
          line.scan /[^"# ]\{/ do |match|
            add_lint(index + 1, 'Opening curly braces ({) should be preceded by at least one space')
          end
        else
          line.scan /[^"#](?<![^ ] )\{/ do |match|
            add_lint(index + 1, 'Opening curly braces ({) should be preceded by one space')
          end
        end
      end
    end

    def node_on_single_line(node)
      return if node.source_range.start_pos.line != node.source_range.end_pos.line

      # The Sass parser reports an incorrect source range if the trailing curly
      # brace is on the next line, e.g.
      #
      #   p {
      #   }
      #
      # Since we don't want to count this as a single line node, check if the
      # last character on the first line is an opening curly brace.
      engine.lines[node.line - 1].strip[-1] != '{'
    end
  end
end
