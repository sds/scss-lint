module SCSSLint
  # Checks for the use of double colons with pseudo elements.
  class Linter::PseudoElement < Linter
    include LinterRegistry

    # https://msdn.microsoft.com/en-us/library/windows/apps/hh767361.aspx
    # https://developer.mozilla.org/en-US/docs/Web/CSS/Mozilla_Extensions
    PSEUDO_ELEMENTS = %w[
      after backdrop before first-letter first-line placeholder selection

      -moz-progress-bar -moz-anonymous-block -moz-anonymous-positioned-block
      -moz-canvas -moz-cell-content -moz-focus-inner -moz-focus-outer
      -moz-inline-table -moz-page -moz-page-sequence -moz-pagebreak
      -moz-pagecontent -moz-placeholder -moz-progress-bar -moz-range-thumb
      -moz-range-track -moz-selection -moz-scrolled-canvas -moz-scrolled-content
      -moz-scrolled-page-sequence -moz-svg-foreign-content -moz-table
      -moz-table-cell -moz-table-column -moz-table-column-group -moz-table-outer
      -moz-table-row -moz-table-row-group -moz-viewport -moz-viewport-scroll
      -moz-xul-anonymous-block

      -ms-expand -ms-browse -ms-check -ms-clear -ms-expand -ms-fill
      -ms-fill-lower -ms-fill-upper -ms-reveal -ms-thumb -ms-ticks-after
      -ms-ticks-before -ms-tooltip -ms-track -ms-value

      -webkit-input-placeholder -webkit-progress-bar -webkit-progress-value
      -webkit-resizer -webkit-scrollbar -webkit-scrollbar-button
      -webkit-scrollbar-corner -webkit-scrollbar-thumb -webkit-scrollbar-track
      -webkit-scrollbar-track-piece
    ]

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
