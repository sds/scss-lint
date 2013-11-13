module SCSSLint
  class LinterError < StandardError; end
  class NoFilesError < StandardError; end
  class NoLintersError < StandardError; end

  # Finds and aggregates all lints found by running the registered linters
  # against a set of SCSS files.
  class Runner
    attr_reader :linters, :lints

    def initialize(config)
      @lints = []
      @linters = LinterRegistry.linters.map(&:new)
    end

    def run(files = [])
      raise NoFilesError, 'No SCSS files specified' if files.empty?
      raise NoLintersError, 'No linters specified' if linters.empty?

      files.each do |file|
        find_lints(file)
      end

      @linters.each do |linter|
        @lints += linter.lints
      end
    end

  private

    def find_lints(file)
      engine = Engine.new(file)

      @linters.each do |linter|
        begin
          linter.run(engine)
        rescue => error
          raise LinterError,
                "#{linter.class} raised unexpected error linting file #{file}: " <<
                "'#{error.message}'",
                error.backtrace
        end
      end
    rescue Sass::SyntaxError => ex
      @lints << Lint.new(ex.sass_filename, ex.sass_line, ex.to_s, :error)
    end
  end
end
