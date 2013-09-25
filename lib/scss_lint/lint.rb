module SCSSLint
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
