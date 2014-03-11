module SCSSLint
  # Defines common functionality available to all linters.
  class Linter < Sass::Tree::Visitors::Base
    include SelectorVisitor
    include Utils

    attr_reader :config, :engine, :lints

    def initialize
      @lints = []
    end

    # @param engine [Engine]
    # @param config [Config]
    def run(engine, config)
      @config = config
      @engine = engine
      visit(engine.tree)
    end

    # Define if you want a default message for your linter
    # @return [String, nil]
    def description
      nil
    end

    # Helper for creating lint from a parse tree node
    #
    # @param node_or_line [Sass::Script::Tree::Node, Sass::Engine::Line]
    # @param message [String, nil]
    def add_lint(node_or_line, message = nil)
      line = node_or_line.respond_to?(:line) ? node_or_line.line : node_or_line

      @lints << Lint.new(engine.filename,
                         line,
                         message || description)
    end

    # @param source_position [Sass::Source::Position]
    # @param offset [Integer]
    # @return [String] the character at the given [Sass::Source::Position]
    def character_at(source_position, offset = 0)
      actual_line   = source_position.line - 1
      actual_offset = source_position.offset + offset - 1

      # Return a newline if offset points at the very end of the line
      return "\n" if actual_offset == engine.lines[actual_line].length

      engine.lines[actual_line][actual_offset]
    end

    # Extracts the original source code given a range.
    #
    # @param source_range [Sass::Source::Range]
    # @return [String] the original source code
    def source_from_range(source_range)
      current_line = source_range.start_pos.line - 1
      last_line    = source_range.end_pos.line - 1
      start_pos    = source_range.start_pos.offset - 1

      if current_line == last_line
        source = engine.lines[current_line][start_pos..(source_range.end_pos.offset - 1)]
      else
        source = engine.lines[current_line][start_pos..-1]
      end

      current_line += 1
      while current_line < last_line
        source += "#{engine.lines[current_line]}\n"
        current_line += 1
      end

      if source_range.start_pos.line != source_range.end_pos.line &&
         # Sometimes the parser reports ranges ending on the first column of the
         # line after the last line; don't include the last line in this case.
         engine.lines.count == current_line - 1
        source += "#{engine.lines[current_line][0...source_range.end_pos.offset]}\n"
      end

      source
    end

    # Modified so we can also visit selectors in linters
    #
    # @param node [Sass::Tree::Node, Sass::Script::Tree::Node,
    #   Sass::Script::Value::Base]
    def visit(node)
      # Visit the selector of a rule if parsed rules are available
      if node.is_a?(Sass::Tree::RuleNode) && node.parsed_rules
        visit_selector(node.parsed_rules)
      end

      super
    end

    # Redefine so we can set the `node_parent` of each node
    #
    # @param parent [Sass::Tree::Node, Sass::Script::Tree::Node,
    #   Sass::Script::Value::Base]
    def visit_children(parent)
      parent.children.each do |child|
        child.node_parent = parent
        visit(child)
      end
    end
  end
end
