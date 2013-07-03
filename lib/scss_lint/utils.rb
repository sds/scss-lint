module SCSSLint
  module Utils
    # Given a selector array which is a list of strings with Sass::Script::Nodes
    # interspersed within them, return an array of strings representing those
    # selectors with the Sass::Script::Nodes removed (i.e., ignoring
    # interpolation). For example:
    #
    # .selector-one, .selector-#{$var}-two
    #
    # becomes:
    #
    # .selector-one, .selector--two
    #
    # This is useful for lints that wish to ignore interpolation, since
    # interpolation can't be resolved at this step.
    def extract_string_selectors(selector_array)
      selector_array.reject { |item| item.is_a? Sass::Script::Node }.
                     join.
                     split
    end

    # Given a selector array, returns whether it contains any placeholder
    # selectors with invalid names.
    def selector_has_bad_placeholder?(selector_array)
      extract_string_selectors(selector_array).any? do |selector_str|
        selector_str =~ /%\w*#{INVALID_NAME_CHARS}/
      end
    end

    def node_has_bad_name?(node)
      node.name =~ /#{INVALID_NAME_CHARS}/
    end

  private

    INVALID_NAME_CHARS = '[_A-Z]'
  end
end
