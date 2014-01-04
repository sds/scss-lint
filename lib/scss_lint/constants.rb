# Global application constants.
module SCSSLint
  SCSS_LINT_HOME = File.realpath(File.join(File.dirname(__FILE__), '..', '..'))
  SCSS_LINT_DATA = File.join(SCSS_LINT_HOME, 'data')

  REPO_URL = 'https://github.com/causes/scss-lint'
  BUG_REPORT_URL = "#{REPO_URL}/issues"
end
