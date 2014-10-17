module SCSSLint
  # Checks formatting of the basenames of @imported partials
  class Linter::ImportPartial < Linter
    include LinterRegistry

    def visit_import(node)
      # Simply return if the node is interpreted as a CSS import
      node.css_import?
    rescue
      # Otherwise, check it
      basename = node.imported_filename.split('/')[-1]
      ok = check_underscore(basename) && check_extension(basename)
      return if ok
      add_lint(node, compose_message)
    end

  private

    def check_underscore(basename)
      underscore_exists = basename.start_with?('_')
      config['leading_underscore'] ? underscore_exists : !underscore_exists
    end

    def check_extension(basename)
      extension_exists = basename.end_with?('.scss')
      config['filename_extension'] ? extension_exists : !extension_exists
    end

    def compose_message
      underscore_modifier = config['leading_underscore'] ? 'should' : 'should not'
      extension_modifier = config['filename_extension'] ? 'should' : 'should not'
      "The basenames of @imported SCSS partials #{underscore_modifier} begin " \
      "with an underscore, and #{extension_modifier} include the filename extension"
    end
  end
end
