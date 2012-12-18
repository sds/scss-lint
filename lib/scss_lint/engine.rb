require 'sass'

module SCSSLint
  class Engine
    ENGINE_OPTIONS = { cache: false, syntax: :scss }

    attr_reader :contents

    def initialize(scss_or_filename)
      if File.exists?(scss_or_filename)
        @engine = Sass::Engine.for_file(scss_or_filename, ENGINE_OPTIONS)
        @contents = File.open(scss_or_filename, 'r').read
      else
        @engine = Sass::Engine.new(scss_or_filename, ENGINE_OPTIONS)
        @contents = scss_or_filename
      end
    end

    def tree
      @engine.to_tree
    end
  end
end
