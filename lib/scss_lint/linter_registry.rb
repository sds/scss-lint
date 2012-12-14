module SCSSLint
  module LinterRegistry
    @linters = []

    class << self
      attr_reader :linters

      def included(base)
        @linters << base
      end
    end
  end
end
