module SCSSLint
  # Responsible for displaying lints to the user in some format.
  class Reporter
    attr_reader :lints, :files

    def self.descendants
      ObjectSpace.each_object(Class).select { |klass| klass < self }
    end

    # @param lints [List<Lint>] a list of Lints sorted by file and line number
    # @param files [List<String>] a list of the files that were linted
    def initialize(lints, files)
      @lints = lints
      @files = files
    end

    def report_lints
      raise NotImplementedError, 'You must implement report_lints'
    end
  end
end
