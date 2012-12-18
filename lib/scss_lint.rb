require 'find'

module SCSSLint
  autoload :Engine, 'scss_lint/engine'
  autoload :Lint, 'scss_lint/lint'
  autoload :LinterRegistry, 'scss_lint/linter_registry'
  autoload :Linter, 'scss_lint/linter'
  autoload :Runner, 'scss_lint/runner'

  # Load all linters
  Dir[File.expand_path('scss_lint/linter/*.rb', File.dirname(__FILE__))].each do |file|
    require file
  end

  class << self
    def extract_files_from(list)
      files = []
      list.each do |file|
        Find.find(file) do |f|
          files << f
        end
      end
      files.uniq
    end
  end
end
