module SCSSLint
  class NoFilesError < StandardError; end

  # Finds and aggregates all lints found by running the registered linters
  # against a set of SCSS files.
  class Runner
    attr_reader :lints

    # @param config [Config]
    def initialize(config)
      @config  = config
      @lints   = []
      @linters = LinterRegistry.linters.map(&:new)
    end

    # @param files [Array]
    def run(files)
      raise NoFilesError, 'No SCSS files specified' if files.empty?

      files.each do |file|
        find_lints(file)
      end

      @linters.each do |linter|
        @lints += linter.lints
      end
    end

  private

    # @param file [String]
    def find_lints(file)
      engine = Engine.new(file)

      @linters.each do |linter|
        begin
          run_linter(linter, engine, file)
        rescue => error
          raise SCSSLint::Exceptions::LinterError,
                "#{linter.class} raised unexpected error linting file #{file}: " \
                "'#{error.message}'",
                error.backtrace
        end
      end
    rescue Sass::SyntaxError => ex
      @lints << Lint.new(nil, ex.sass_filename, Location.new(ex.sass_line),
                         "Syntax Error: #{ex}", :error)
    rescue FileEncodingError => ex
      @lints << Lint.new(nil, file, Location.new, ex.to_s, :error)
    end

    # For stubbing in tests.
    def run_linter(linter, engine, file)
      return unless @config.linter_enabled?(linter)
      return if @config.excluded_file_for_linter?(file, linter)
      linter.run(engine, @config.linter_options(linter))
    end
  end
end
