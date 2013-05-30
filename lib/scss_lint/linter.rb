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
  end
end
