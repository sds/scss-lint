module SCSSLint
  class Linter
    include LinterRegistry

    class << self
      def run(engine)
        [] # No lints
      end

      def create_lint(node)
        Lint.new(node, description)
      end

      def description
        nil
      end

    protected

      def name
        self.class.name
      end
    end
  end
end
