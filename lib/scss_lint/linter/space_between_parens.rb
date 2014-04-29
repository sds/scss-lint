module SCSSLint
  # Checks for the presence of spaces between parentheses.
  class Linter::SpaceBetweenParens < Linter
    include LinterRegistry

    def visit_root(_node)
      @spaces = config['spaces']

      engine.lines.each_with_index do |line, index|
        line.gsub(%r{((//|/\*).*$)}, '').scan(/
          (^(\t|\s)*\))?  # Capture leading spaces and tabs followed by a `)`
          (
            \([ ]*(?!$)   # Find `( ` as long as its not EOL )
            |
            [ ]*\)
          )?
        /x) do |match|
          check(match[2], index) if match[2]
        end
      end
    end

  private

    def check(str, index)
      spaces = str.count ' '
      return if spaces == @spaces

      location = Location.new(index + 1)
      message = "Expected #{pluralize(@spaces, 'space')} " \
                "between parentheses instead of #{spaces}"
      add_lint(location, message)
    end
  end
end
