module SCSSLint
  class Lint
    attr_reader :filename, :line, :description

    def initialize(filename, line, description)
      @filename = filename
      @line = line
      @description = description
    end
  end
end
