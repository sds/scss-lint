module SCSSLint
  # Stores information about a single problem that was detected by a [Linter].
  class Lint
    attr_reader :filename, :location, :description, :severity

    # @param filename [String]
    # @param location [SCSSLint::Location]
    # @param description [String]
    # @param severity [Symbol]
    def initialize(filename, location, description, severity = :warning)
      @filename    = filename
      @location    = location
      @description = description
      @severity    = severity
    end

    # @return [Boolean]
    def error?
      severity == :error
    end
  end
end
