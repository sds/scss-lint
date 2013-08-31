module SCSSLint
  class Linter::HexLinter < Linter
    include LinterRegistry

    def visit_root(node)
      # We can't do this via the parse tree because the parser automatically
      # normalizes all colors encountered in Sass script, so we lose the ability
      # to check the format of the color. Thus we resort to line-by-line regex
      # matching.
      engine.lines.each_with_index do |line, index|
        line.scan /#(\h{3,6})/ do |match|
          unless valid_hex?(match.first)
            @lints << Lint.new(engine.filename, index + 1, description)
          end
        end
      end
    end

    def description
      'Hexadecimal color codes should be lowercase and in 3-digit form where possible'
    end

  private

    def valid_hex?(hex)
      [3,6].include?(hex.length) &&
        hex.downcase == hex &&
        !can_be_condensed(hex)
    end

    def can_be_condensed(hex)
      hex.length == 6 &&
        hex[0] == hex[1] &&
        hex[2] == hex[3] &&
        hex[4] == hex[5]
    end
  end
end
