module SCSSLint
  # Checks for the use of double colons with pseudo elements.
  class Linter::PseudoElement < Linter
    include LinterRegistry

    # https://msdn.microsoft.com/en-us/library/windows/apps/hh767361.aspx
    # https://developer.mozilla.org/en-US/docs/Web/CSS/Mozilla_Extensions
    # http://tjvantoll.com/2013/04/15/list-of-pseudo-elements-to-style-form-controls/
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

      -webkit-calendar-picker-indicator
      -webkit-color-swatch
      -webkit-color-swatch-wrapper
      -webkit-datetime-edit
      -webkit-datetime-edit-day-field
      -webkit-datetime-edit-fields-wrapper
      -webkit-datetime-edit-month-field
      -webkit-datetime-edit-text
      -webkit-datetime-edit-year-field
      -webkit-file-upload-button
      -webkit-inner-spin-button
      -webkit-input-placeholder
      -webkit-keygen-select
      -webkit-meter-bar
      -webkit-meter-even-less-good-value
      -webkit-meter-optimum-value
      -webkit-meter-suboptimum-value
      -webkit-outer-spin-button
      -webkit-progress-bar
      -webkit-progress-inner-element
      -webkit-progress-value
      -webkit-resizer
      -webkit-scrollbar
      -webkit-scrollbar-button
      -webkit-scrollbar-corner
      -webkit-scrollbar-thumb
      -webkit-scrollbar-track
      -webkit-scrollbar-track-piece
      -webkit-search-cancel-button
      -webkit-search-results-button
      -webkit-slider-runnable-track
      -webkit-slider-thumb
      -webkit-textfield-decoration-container
      -webkit-validation-bubble
      -webkit-validation-bubble-arrow
      -webkit-validation-bubble-arrow-clipper
      -webkit-validation-bubble-heading
      -webkit-validation-bubble-message
      -webkit-validation-bubble-text-block
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
