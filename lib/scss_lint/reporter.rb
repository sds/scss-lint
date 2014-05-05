module SCSSLint
  # Responsible for displaying lints to the user in some format.
  class Reporter
    attr_reader :lints

    def self.descendants
      ObjectSpace.each_object(Class).select { |klass| klass < self }
    end

    def initialize(lints)
      @lints = lints
    end

    def report_lints
      raise NotImplementedError, 'You must implement report_lints'
    end
  end
end
