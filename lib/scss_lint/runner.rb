module SCSSLint
  class LinterError < StandardError; end
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
      config = @config.preferred ? @config : Config.for_file(file)
      config ||= @config

      @linters.each do |linter|
        next unless config.linter_enabled?(linter)
        next if config.excluded_file_for_linter?(file, linter)

        begin
          run_linter(linter, engine, config)
        rescue => error
          raise LinterError,
                "#{linter.class} raised unexpected error linting file #{file}: " \
                "'#{error.message}'",
                error.backtrace
        end
      end
    rescue Sass::SyntaxError => ex
      @lints << Lint.new(nil, ex.sass_filename, Location.new(ex.sass_line), ex.to_s, :error)
    rescue FileEncodingError => ex
      @lints << Lint.new(nil, file, Location.new, ex.to_s, :error)
    end

    # For stubbing in tests.
    def run_linter(linter, engine, config)
      linter.run(engine, config.linter_options(linter))
    end
  end
end
