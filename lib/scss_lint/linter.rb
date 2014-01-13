module SCSSLint
  # Defines common functionality available to all linters.
  class Linter < Sass::Tree::Visitors::Base
    include SelectorVisitor
    include Utils

    attr_reader :config, :engine, :lints

    def initialize
      @lints = []
    end

    def run(engine, config)
      @config = config
      @engine = engine
      visit(engine.tree)
    end

    # Define if you want a default message for your linter
    def description
      nil
    end

    # Helper for creating lint from a parse tree node
    def add_lint(node_or_line, message = nil)
      line = node_or_line.respond_to?(:line) ? node_or_line.line : node_or_line

      @lints << Lint.new(engine.filename,
                         line,
                         message || description)
    end

    # Returns the character at the given [Sass::Source::Position]
    def character_at(source_position, offset = 0)
      actual_line = source_position.line - 1
      actual_offset = source_position.offset + offset - 1

      # Return a newline if offset points at the very end of the line
      return "\n" if actual_offset == engine.lines[actual_line].length

      engine.lines[actual_line][actual_offset]
    end

    # Extracts the original source code given a range.
    def source_from_range(source_range)
      current_line = source_range.start_pos.line - 1
      last_line = source_range.end_pos.line - 1

      source = engine.lines[current_line][(source_range.start_pos.offset - 1)..-1]

      current_line += 1
      while current_line < last_line
        source += "#{engine.lines[current_line]}\n"
        current_line += 1
      end

      if source_range.start_pos.line != source_range.end_pos.line
        source += "#{engine.lines[current_line][0...source_range.end_pos.offset]}\n"
      end

      source
    end

    # Monkey-patched implementation that adds support for traversing
    # Sass::Script::Nodes (original implementation only supports
    # Sass::Tree::Nodes).
    def self.node_name(node)
      case node
      when Sass::Script::Tree::Node, Sass::Script::Value::Base
        "script_#{node.class.name.gsub(/.*::(.*?)$/, '\\1').downcase}"
      else
        super
      end
    end

    # Modified so we can also visit selectors in linters
    def visit(node)
      # Visit the selector of a rule if parsed rules are available
      if node.is_a?(Sass::Tree::RuleNode) && node.parsed_rules
        visit_selector(node.parsed_rules)
      end

      super
    end

    # Redefine so we can set the `node_parent` of each node
    def visit_children(parent)
      parent.children.each do |child|
        child.node_parent = parent
        visit(child)
      end
    end
  end
end
