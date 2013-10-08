module SCSSLint
  class Linter < Sass::Tree::Visitors::Base
    include SelectorVisitor
    include Utils

    attr_reader :engine, :lints

    def initialize
      @lints = []
    end

    def run(engine)
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

    # Monkey-patched implementation that adds support for traversing
    # Sass::Script::Nodes (original implementation only supports
    # Sass::Tree::Nodes).
    def node_name(node)
      if node.is_a?(Sass::Script::Node)
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
