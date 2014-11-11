module SCSSLint::Exceptions
  # Raised when an invalid flag is given via the command line.
  class InvalidCLIOption < StandardError; end

  # Raised when an unexpected error occurs in a linter
  class LinterError < StandardError; end
end
