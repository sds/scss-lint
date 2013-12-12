module SCSSLint
  # Stores information about a single problem that was detected by a [Linter].
  class Lint
    attr_reader :filename, :line, :description, :severity

    def initialize(filename, line, description, severity = :warning)
      @filename = filename
      @line = line
      @description = description
      @severity = severity
    end

    def error?
      severity == :error
    end
  end
end
