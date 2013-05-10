require 'sass'

module SCSSLint
  class Linter::SingleLinePerSelector < Linter
    include LinterRegistry

    def visit_rule(node)
      add_lint(node) if invalid_comma_placement? node
      yield # Continue linting children
    end

    def description
      'Each selector should be on its own line'
    end

  private

    # A comma is invalid if it starts the line or is not the end of the line
    def invalid_comma_placement?(node)
      normalize_spacing(condense_to_string(node.rule)) =~ /\n,|,[^\n]/
    end

    # Since RuleNode.rule returns an array containing both String and
    # Sass::Script::Nodes, we need to condense it into a single string that we
    # can run a regex against.
    def condense_to_string(sequence_list)
      sequence_list.inject('') do |combined, string_or_script|
        combined + (string_or_script.is_a?(String) ? string_or_script
                                                   : string_or_script.to_sass)
      end
    end

    # Removes extra spacing between lines in a comma-separated sequence due to
    # comments being removed in the parse phase. This makes it easy to check if
    # a comma is where belongs.
    def normalize_spacing(string_sequence)
      string_sequence.gsub(/,[^\S\n]*\n\s*/, ",\n")
    end
  end
end
