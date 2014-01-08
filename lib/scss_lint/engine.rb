require 'sass'

module SCSSLint
  class FileEncodingError < StandardError; end

  # Contains all information for a parsed SCSS file, including its name,
  # contents, and parse tree.
  class Engine
    ENGINE_OPTIONS = { cache: false, syntax: :scss }

    attr_reader :contents, :filename, :lines, :tree

    def initialize(scss_or_filename)
      if File.exists?(scss_or_filename)
        @filename = scss_or_filename
        @engine = Sass::Engine.for_file(scss_or_filename, ENGINE_OPTIONS)
        @contents = File.open(scss_or_filename, 'r').read
      else
        @engine = Sass::Engine.new(scss_or_filename, ENGINE_OPTIONS)
        @contents = scss_or_filename
      end

      @lines = @contents.split("\n")
      @tree = @engine.to_tree
    rescue ArgumentError => error
      if error.message.include?('invalid byte sequence')
        raise FileEncodingError,
              "Unable to parse SCSS file: #{error.to_s}",
              error.backtrace
      else
        raise
      end
    end
  end
end
