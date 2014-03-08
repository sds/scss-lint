module SCSSLint
  # Stores information about a single problem that was detected by a [Linter].
  class Lint
    attr_reader :filename, :line, :description, :severity

    # @param filename [String]
    # @param line [Integer]
    # @param description [String]
    # @param severity [Symbol]
    def initialize(filename, line, description, severity = :warning)
      @filename    = filename
      @line        = line
      @description = description
      @severity    = severity
    end

    # @return [Boolean]
    def error?
      severity == :error
    end
  end
end
