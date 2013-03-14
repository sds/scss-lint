module SCSSLint
  class Reporter
    attr_reader :lints

    def initialize(lints)
      @lints = lints
    end

    def report_lints
      raise NotImplementedError, 'You must implement report_lints'
    end
  end
end
