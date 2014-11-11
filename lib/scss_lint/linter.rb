module SCSSLint
  # Defines common functionality available to all linters.
  class Linter < Sass::Tree::Visitors::Base
    include SelectorVisitor
    include Utils

    attr_reader :config, :engine, :lints

    def initialize
      @lints = []
    end

    # Run this linter against a parsed document with a given configuration.
    #
    # @param engine [Engine]
    # @param config [Config]
    def run(engine, config)
      @config = config
      @engine = engine
      visit(engine.tree)
    end

    # Return the human-friendly name of this linter as specified in the
    # configuration file and in lint descriptions.
    def name
      self.class.name.split('::')[2..-1].join('::')
    end

  protected

    # Helper for creating lint from a parse tree node
    #
    # @param node_or_line_or_location [Sass::Script::Tree::Node, Fixnum, SCSSLint::Location]
    # @param message [String]
    def add_lint(node_or_line_or_location, message)
      @lints << Lint.new(self,
                         engine.filename,
                         extract_location(node_or_line_or_location),
                         message,
                         @config.fetch('severity', :warning).to_sym)
    end

    # Extract {SCSSLint::Location} from a {Sass::Source::Range}.
    #
    # @param range [Sass::Source::Range]
    # @return [SCSSLint::Location]
    def location_from_range(range) # rubocop:disable Metrics/AbcSize
      length = if range.start_pos.line == range.end_pos.line
                 range.end_pos.offset - range.start_pos.offset
               else
                 line_source = engine.lines[range.start_pos.line - 1]
                 line_source.length - range.start_pos.offset + 1
               end

      Location.new(range.start_pos.line, range.start_pos.offset, length)
    end

    # @param source_position [Sass::Source::Position]
    # @param offset [Integer]
    # @return [String] the character at the given [Sass::Source::Position]
    def character_at(source_position, offset = 0)
      actual_line   = source_position.line - 1
      actual_offset = source_position.offset + offset - 1

      engine.lines[actual_line][actual_offset]
    end

    # Extracts the original source code given a range.
    #
    # @param source_range [Sass::Source::Range]
    # @return [String] the original source code
    def source_from_range(source_range) # rubocop:disable Metrics/AbcSize
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
        source += "#{engine.lines[current_line]}"
        current_line += 1
      end

      if source_range.start_pos.line != source_range.end_pos.line
        source += "#{(engine.lines[current_line] || '')[0...source_range.end_pos.offset]}"
      end

      source
    end

    # Returns whether a given node spans only a single line.
    #
    # @param node [Sass::Tree::Node]
    # @return [true,false] whether the node spans a single line
    def node_on_single_line?(node)
      return if node.source_range.start_pos.line != node.source_range.end_pos.line

      # The Sass parser reports an incorrect source range if the trailing curly
      # brace is on the next line, e.g.
      #
      #   p {
      #   }
      #
      # Since we don't want to count this as a single line node, check if the
      # last character on the first line is an opening curly brace.
      engine.lines[node.line - 1].strip[-1] != '{'
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

  private

    def extract_location(node_or_line_or_location)
      if node_or_line_or_location.is_a?(Location)
        node_or_line_or_location
      elsif node_or_line_or_location.respond_to?(:source_range) &&
            node_or_line_or_location.source_range
        location_from_range(node_or_line_or_location.source_range)
      elsif node_or_line_or_location.respond_to?(:line)
        Location.new(node_or_line_or_location.line)
      else
        Location.new(node_or_line_or_location)
      end
    end
  end
end
