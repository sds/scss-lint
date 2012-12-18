require 'sass'

module SCSSLint
  class Linter::DebugLinter < Linter
    include LinterRegistry

    class << self
      def run(engine)
        lints = []
        engine.tree.each do |node|
          lints << create_lint(node) if node.is_a?(Sass::Tree::DebugNode)
        end
        lints
      end

      def description
        '@debug line'
      end
    end
  end
end
