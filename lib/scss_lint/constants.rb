# Global application constants.
module SCSSLint
  SCSS_LINT_HOME = File.realpath(File.join(File.dirname(__FILE__), '..', '..'))

  REPO_URL = 'https://github.com/causes/scss-lint'
  BUG_REPORT_URL = "#{REPO_URL}/issues"
end
