module SCSSLint
  # Checks for a selector with an ID combined with some other selector.
  class Linter::IdWithExtraneousSelector < Linter
    include LinterRegistry

    def visit_simple_sequence(seq)
      id_sel = seq.members.find { |simple| simple.is_a?(Sass::Selector::Id) }
      return unless id_sel

      if seq.members.any? { |simple| !simple.is_a?(Sass::Selector::Id) && !simple.is_a?(Sass::Selector::Pseudo) }
        add_lint(seq, "Selector `#{seq}` can be simplified to `#{id_sel}`, " <<
                      'since IDs should be uniquely identifying')
      end
    end
  end
end
