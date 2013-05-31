require 'find'

module SCSSLint
  autoload :CLI, 'scss_lint/cli'
  autoload :Engine, 'scss_lint/engine'
  autoload :Lint, 'scss_lint/lint'
  autoload :LinterRegistry, 'scss_lint/linter_registry'
  autoload :Linter, 'scss_lint/linter'
  autoload :Reporter, 'scss_lint/reporter'
  autoload :Runner, 'scss_lint/runner'
  autoload :VERSION, 'scss_lint/version'

  # Preload Sass so we can monkey patch it
  require 'sass'
  require 'sass/tree'

  # Load all linters
  Dir[File.expand_path('scss_lint/linter/*.rb', File.dirname(__FILE__))].each do |file|
    require file
  end

  # Load all reporters
  Dir[File.expand_path('scss_lint/reporter/*.rb', File.dirname(__FILE__))].each do |file|
    require file
  end

  class << self
    def extract_files_from(list)
      files = []
      list.each do |file|
        Find.find(file) do |f|
          files << f if scssish_file?(f)
        end
      end
      files.uniq
    end

  private

    VALID_EXTENSIONS = %w[.css .scss]
    def scssish_file?(file)
      return false unless FileTest.file?(file)

      VALID_EXTENSIONS.include?(File.extname(file))
    end
  end
end
