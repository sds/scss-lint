module SCSSLint
  # Checks for uses of chained classes (e.g. .foo.bar).
  class Linter::ChainedClasses < Linter
    include LinterRegistry

    def visit_sequence(sequence)
      sequence.members.each do |simple_sequence|
        next unless chained_class?(simple_sequence)
        add_lint(simple_sequence.line,
                 'Prefer using a distinct class over chained classes ' \
                 '(e.g. .new-class over .foo.bar')
      end
    end

  private

    def chained_class?(simple_sequence)
      simple_sequence.members.count { |member| member.is_a?(Sass::Selector::Class) } >= 2
    end
  end
end
