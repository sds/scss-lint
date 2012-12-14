module SCSSLint
  class Lint
    attr_reader :filename, :line, :description

    def initialize(node, description)
      @filename = node.filename
      @line = node.line
      @description = description
    end
  end
end
