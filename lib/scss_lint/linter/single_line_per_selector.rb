module SCSSLint
  # Checks that selector sequences are split over multiple lines by comma.
  class Linter::SingleLinePerSelector < Linter
    include LinterRegistry

    MESSAGE = 'Each selector in a comma sequence should be on its own single line'

    def visit_comma_sequence(node)
      return unless node.members.count > 1

      check_comma_on_own_line(node)

      line_offset = 0
      node.members[1..-1].each do |sequence|
        line_offset += 1 if sequence_start_of_line?(sequence)
        check_sequence_commas(node, sequence, line_offset)
      end
    end

    def visit_sequence(node)
      node.members[1..-1].each_with_index do |item, index|
        next unless item == "\n"

        add_lint(node.line + index, MESSAGE)
      end
    end

  private

    def sequence_start_of_line?(sequence)
      sequence.members[0] == "\n"
    end

    def check_comma_on_own_line(node)
      return unless node.members[0].members[1] == "\n"
      add_lint(node, MESSAGE)
    end

    def check_sequence_commas(node, sequence, index)
      if !sequence_start_of_line?(sequence)
        # Next sequence doesn't reside on its own line
        add_lint(node.line + index, MESSAGE)
      elsif sequence.members[1] == "\n"
        # Comma is on its own line
        add_lint(node.line + index, MESSAGE)
      end
    end
  end
end
