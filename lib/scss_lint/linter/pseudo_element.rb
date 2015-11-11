module SCSSLint
  # Checks for the use of double colons with pseudo elements.
  class Linter::PseudoElement < Linter
    include LinterRegistry

    PSEUDO_ELEMENTS = %w[after backdrop before first-letter first-line selection]

    def visit_pseudo(pseudo)
      if PSEUDO_ELEMENTS.include?(pseudo.name)
        return if pseudo.syntactic_type == :element
        add_lint(pseudo, 'Begin pseudo elements with double colons: `::`')
      else
        return if pseudo.syntactic_type != :element
        add_lint(pseudo, 'Begin pseudo classes with a single colon: `:`')
      end
    end
  end
end
