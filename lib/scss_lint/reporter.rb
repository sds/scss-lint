module SCSSLint
  # Responsible for displaying lints to the user in some format.
  class Reporter
    attr_reader :lints, :files, :log, :lints_run_count

    def self.descendants
      ObjectSpace.each_object(Class).select { |klass| klass < self }
    end

    # @param lints [List<Lint>] a list of Lints sorted by file and line number
    # @param files [List<Hash>] a list of the files that were linted
    # @param logger [SCSSLint::Logger]
    def initialize(lints, files, logger, lints_run_count = nil)
      @lints = lints
      @files = files
      @log = logger
      @lints_run_count = lints_run_count
    end

    def report_lints
      raise NotImplementedError, 'You must implement report_lints'
    end

  private

    def log_with_level(msg)
      log.public_send(log_level, msg)
    end

    def log_level
      if lints.any?(&:error?)
        :error
      elsif lints.any?
        :warning
      else
        :info
      end
    end
  end
end
