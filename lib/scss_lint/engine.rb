require 'sass'

module SCSSLint
  class Engine
    ENGINE_OPTIONS = { syntax: :scss }

    def initialize(scss_or_filename)
      if File.exists?(scss_or_filename)
        @engine = Sass::Engine.for_file(scss_or_filename, ENGINE_OPTIONS)
      else
        @engine = Sass::Engine.new(scss_or_filename, ENGINE_OPTIONS)
      end
    end

    def tree
      @engine.to_tree
    end
  end
end
