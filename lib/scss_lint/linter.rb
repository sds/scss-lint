module SCSSLint
  class Linter < Sass::Tree::Visitors::Base
    include LinterRegistry

    attr_reader :engine, :lints

    def initialize
      @lints = []
    end

    def run(engine)
      @engine = engine
      visit(engine.tree)
    end

    def description
      nil
    end

  protected

    # Helper for creating lint from a parse tree node
    def add_lint(node)
      @lints << Lint.new(engine.filename, node.line, description)
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
  end
end
