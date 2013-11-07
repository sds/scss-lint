require 'find'

module SCSSLint
  autoload :CLI, 'scss_lint/cli'
  autoload :Engine, 'scss_lint/engine'
  autoload :Lint, 'scss_lint/lint'
  autoload :LinterRegistry, 'scss_lint/linter_registry'
  autoload :Linter, 'scss_lint/linter'
  autoload :Reporter, 'scss_lint/reporter'
  autoload :Runner, 'scss_lint/runner'
  autoload :SelectorVisitor, 'scss_lint/selector_visitor'
  autoload :Utils, 'scss_lint/utils'

  require 'scss_lint/constants'
  require 'scss_lint/version'

  # Preload Sass so we can monkey patch it
  require 'sass'
  require File.expand_path('scss_lint/sass/script', File.dirname(__FILE__))
  require File.expand_path('scss_lint/sass/tree', File.dirname(__FILE__))

  # Load all linters in sorted order, since ordering matters and some systems
  # return the files in an order which loads a child class before the parent.
  Dir[File.expand_path('scss_lint/linter/**/*.rb', File.dirname(__FILE__))].sort.each do |file|
    require file
  end

  # Load all reporters
  Dir[File.expand_path('scss_lint/reporter/*.rb', File.dirname(__FILE__))].sort.each do |file|
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
