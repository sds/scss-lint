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

    def node_has_bad_name?(node)
      node.name =~ /#{INVALID_NAME_CHARS}/
    end

    def shortest_hex_form(hex)
      (can_be_condensed?(hex) ? (hex[0..1] + hex[3] + hex[5]) : hex).downcase
    end

    def can_be_condensed?(hex)
      hex.length == 7 &&
        hex[1] == hex[2] &&
        hex[3] == hex[4] &&
        hex[5] == hex[6]
    end

    # Takes a string like `hello "world" 'how are' you` and turns it into:
    # `hello   you`.
    # This is useful for scanning for keywords in shorthand properties or lists
    # which can contain quoted strings but for which you don't want to inspect
    # quoted strings (e.g. you care about the actual color keyword `red`, not
    # the string "red").
    def remove_quoted_strings(string)
      string.gsub(/"[^"]*"|'[^']*'/, '')
    end

    def previous_node(node)
      return unless node && parent = node.node_parent
      index = parent.children.index(node)

      if index == 0
        parent
      else
        parent.children[index - 1]
      end
    end

    # HACK: Since the Sass parser does not store the file ranges/offsets of the
    # nodes of the parse tree, we have to infer when a node is spread across
    # multiple lines. Sass always sets the line of a node to be the last line it
    # spans, so we can use this information to deduce its starting line.
    #
    # If a node has a node that comes before it, we know that the previous
    # node's line can be followed by either empty lines, or the first line of
    # the next node. We can work backwards from the line of the given node to
    # find the first empty line or stop if we're at the end of the previous
    # node.
    def node_start_line(node, engine)
      return unless node.line

      previous = previous_node(node)

      last_line = if previous && previous.line && !previous.is_a?(Sass::Tree::RootNode)
                    previous.line
                  else
                    0
                  end

      current_line = node.line

      while current_line - 1 > last_line
        line_contents = engine.lines[current_line - 2].strip

        # Blank lines or lines that start/end a block are indications that we've
        # hit the end of the previous node
        break if line_contents.empty? || line_contents.end_with?('{', '}')
        current_line -= 1
      end

      current_line
    end

  private

    INVALID_NAME_CHARS = '[_A-Z]'
  end
end
