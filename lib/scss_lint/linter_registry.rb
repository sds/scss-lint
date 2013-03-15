module SCSSLint
  class NoSuchLinter < StandardError; end

  module LinterRegistry
    @linters = []

    class << self
      attr_reader :linters

      def included(base)
        @linters << base
      end

      def extract_linters_from(linter_names)
        linter_names.map do |linter_name|
          begin
            linter_class = linter_name.split('_').map(&:capitalize).join('')
            Kernel.const_get(linter_class)
          rescue NameError
            raise NoSuchLinter.new("Linter #{linter_class} does not exist")
          end
        end
      end
    end
  end
end
