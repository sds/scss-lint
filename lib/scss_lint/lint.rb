module SCSSLint
  # Stores information about a single problem that was detected by a [Linter].
  class Lint
    attr_reader :linter, :filename, :location, :description, :severity, :auto_correct

    # @param linter [SCSSLint::Linter]
    # @param filename [String]
    # @param location [SCSSLint::Location]
    # @param description [String]
    # @param severity [Symbol]
    # rubocop:disable Metrics/ParameterLists:
    def initialize(linter, filename, location, description, severity = :warning, &auto_correct)
      @linter      = linter
      @filename    = filename
      @location    = location
      @description = description
      @severity    = severity
      @auto_correct = auto_correct
    end

    # @return [Boolean]
    def error?
      severity == :error
    end
  end
end
